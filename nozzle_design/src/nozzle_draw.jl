module NozzleDraw
using ..NozzleProject
using ..Unitful
using ConstructiveGeometry
using LinearAlgebra: cross, dot
using Rotations

mm(l::Quantity) = ustrip(Float64, u"mm", l)

get_radius(A) = √(A/π)
get_radii(noz::NozzleAreas)= get_radius(noz.Achamber),
                                get_radius(noz.Athroat),
                                get_radius(noz.Aexit)
export RoundNozzle
struct RoundNozzle
    areas::NozzleAreas
    exit_half_angle::Quantity
    conv_half_angle::Quantity
    chamber_length::Quantity
    thickness::Quantity
end

get_radii(noz::RoundNozzle) = get_radii(noz.areas)

function flow_wall(noz::RoundNozzle)
    rchamber, rthroat, rexit = get_radii(noz)

    return cat.([
        rchamber
        rchamber
        rthroat
        rexit
    ],
        accumulate(+, [
            0u"mm"
            noz.chamber_length
            (rchamber - rthroat) / tan(noz.conv_half_angle)
            (rexit - rthroat) / tan(noz.exit_half_angle) 
        ]), dims=1)
end

function generate_nozzle_contour(flow_wall::Vector, noz::RoundNozzle)
    #fazer parede externa cilíndrica
    max_radius = maximum(first.(flow_wall))
    return [
        flow_wall...,
        [flow_wall[end][1]+noz.thickness, flow_wall[end][2]],
        [max_radius+noz.thickness, noz.chamber_length],
        [max_radius+noz.thickness, -noz.thickness],
        [0u"mm", -noz.thickness]
    ]
end

function generate_solid(contour::Vector)
    float_contour = [
        mm.(point)
        for point in contour
    ]
    return rotate_extrude() * ConstructiveGeometry.polygon(float_contour)
end

function (noz::RoundNozzle)()
    noz |> flow_wall |> fw-> generate_nozzle_contour(fw, noz) |> generate_solid
end

abstract type NozzleFeature end
export ConnectorHole
struct ConnectorHole <: NozzleFeature
    diam::Quantity
    depth::Quantity
    center::Vector{Float64}
    rotation::RotZYX
    function ConnectorHole(d::Quantity, depth::Quantity,
            center::Vector{Float64},
            direction::Vector{Float64})
        ndir = direction/√sum(direction.^2)
        if ndir[1] ≈ 0 && ndir[2] ≈ 0
            axis = [1.0, 0, 0]
        else
            axis = cross([0.0, 0, 1], ndir)
        end
        theta = acos(dot(ndir, [0.0,0,1]))
        new(d, depth, center, RotZYX(AngleAxis(theta, axis...)))
    end
end

function (ch::ConnectorHole)(solid, nozgeom::RoundNozzle)
    solid \ (ch.center + rotate(rad2deg.(
                (ch.rotation.theta1,
                ch.rotation.theta2,
                ch.rotation.theta3)
                ))
            * linear_extrude(mm(ch.depth)+√eps()) * circle(mm(ch.diam)/2))
    # solid \ (ch.center+linear_extrude(mm(ch.depth)) * circle(mm(ch.diam)/2))
end
export HexBase
struct HexBase <: NozzleFeature
    height::Quantity
    clearance::Quantity
end
hexagon(inner_r::Float64) = [(2*inner_r/sqrt(3)) .* reverse(sincospi((i+1/6))) for i in (0:5)/3]

side_length(hb::HexBase, ng::RoundNozzle) =  2/√3 *
         (get_radius(ng.areas.Achamber) + ng.thickness + hb.clearance)

function (hb::HexBase)(solid, nozgeom::RoundNozzle)
    t = mm(nozgeom.thickness)
    out_r = mm(get_radius(nozgeom.areas.Achamber)) + t
    return union(
        solid,
        [0,0,-t] + linear_extrude(mm(hb.height)) *
            (polygon(hexagon(out_r+mm(hb.clearance))) \ circle(out_r))
    )
end

export ProbeHole
struct ProbeHole <: NozzleFeature
    width::Quantity
    height::Quantity
    pad_clearance::Quantity
    diam::Quantity
    z_offset::Quantity
end

function (ph::ProbeHole)(solid, nozgeom::RoundNozzle)
    rchamQ = get_radius(nozgeom.areas.Achamber)
    connhole = ConnectorHole(ph.diam, 
        ph.pad_clearance+rchamQ+nozgeom.thickness,
        [0,0,mm(ph.z_offset+ph.height/2)],
        [1.0,0,0]
    )

    t = mm(nozgeom.thickness)
    rcham = mm(rchamQ)
    len = rcham + t + mm(ph.pad_clearance)
    
    pad_base = ([len/2, 0] + square(len,
                    mm(ph.width),
                    center=true)
                ) \ circle(rcham+t)

    connhole(union(
        solid,
        [0,0, mm(ph.z_offset)] 
        + linear_extrude(mm(ph.height)) * pad_base
    ), nozgeom)
end
export build_nozzle
function build_nozzle(ng::RoundNozzle, features::Vector{NozzleFeature})
    reduce((base, feat) -> feat(base, ng), features, init = ng())
end

function export_stl(file::String, solid; rtol=1e-3, atol=1e-3)
    ConstructiveGeometry.stl(file, solid, rtol=rtol, atol=atol)
end

end
