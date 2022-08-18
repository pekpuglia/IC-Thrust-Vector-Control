module NozzleDraw
using ..NozzleProject
using ..Unitful
using ConstructiveGeometry

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

export flow_wall
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

function build_nozzle(noz::RoundNozzle)
    noz |> flow_wall |> fw-> generate_nozzle_contour(fw, noz) |> generate_solid
end

function add_connector_hole(solid, noz::RoundNozzle, d::Quantity)
    return solid \ ([0,0, -mm(noz.thickness)] + cylinder(mm(noz.thickness), mm(d/2)))
end

function add_stagnator(solid, noz::RoundNozzle, radius_fraction::Float64, chamber_length_fraction::Float64)
    rc = get_radius(noz.areas.Achamber)
    union(solid,
        [0,0,noz.chamber_length*chamber_length_fraction] 
        + linear_extrude(noz.thickness) 
        * square(2*rc+eps(), 2*radius_fraction*rc, center=true)
    )
end

hexagon(inner_r::Float64) = [(2*inner_r/sqrt(3)) .* reverse(sincospi((i))) for i in (0:5)/3]

function add_hexagonal_base(solid, noz::RoundNozzle, height::Real)
    t = mm(noz.thickness)
    out_r = mm(get_radius(noz.areas.Achamber)) + t
    return union(
        solid,
        [0,0,-t] + linear_extrude(height) *
            (polygon(hexagon(out_r+t)) \ circle(out_r))
    )
end

function export_stl(file::String, solid; rtol=1e-3, atol=1e-3)
    ConstructiveGeometry.stl(file, solid, rtol=rtol, atol=atol)
end

end
