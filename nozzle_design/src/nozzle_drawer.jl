include("nozzle_design.jl")


struct NozzleGeometry
    areas::NozzleAreas
    exit_half_angle::Float64
    conv_half_angle::Float64
    chamber_length::Float64
    thickness::Float64
end

using ConstructiveGeometry

get_radius(A::Float64) = √(A/π)

get_radii(noz::NozzleGeometry)= get_radius(noz.areas.Achamber),
                                get_radius(noz.areas.Athroat),
                                get_radius(noz.areas.Aexit)

function generate_ys(noz::NozzleGeometry, rchamber::Float64, rthroat::Float64, rexit::Float64)
    accumulate(+, [
        0
        noz.chamber_length
        (rchamber - rthroat) / tand(noz.conv_half_angle)
        (rexit - rthroat) / tand(noz.exit_half_angle) 
    ])
end

function generate_xs(rchamber::Float64, rthroat::Float64, rexit::Float64)
    [
        rchamber
        rchamber
        rthroat
        rexit
    ]
end

function generate_profile(noz::NozzleGeometry)
    radii = get_radii(noz)
    ys = generate_ys(noz, radii...)
    xs = generate_xs(radii...)

    return [
        [0,0],
        cat.(xs, ys, dims=1)...,
        reverse(cat.(xs .+ noz.thickness, ys, dims=1))...,
        [radii[1], -noz.thickness],
        [0, -noz.thickness]
    ]
end

profile_svg(noz::NozzleGeometry) = ConstructiveGeometry.svg("nozzle.svg", polygon(1000*generate_profile(noz)))

function generate_solid(profile::Vector)
    return rotate_extrude() * ConstructiveGeometry.polygon(profile)
end