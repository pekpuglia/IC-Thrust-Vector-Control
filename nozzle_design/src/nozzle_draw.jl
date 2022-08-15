module NozzleDraw
using ..NozzleProject
using ConstructiveGeometry
function generate_nozzle_contour(nozzlegeom::NozzleGeometry)
    flow_wall= generate_flow_wall(nozzlegeom)
    #fazer parede externa cilíndrica
    max_radius = maximum(first.(flow_wall))
    return [
        flow_wall...,
        [max_radius+nozzlegeom.thickness, flow_wall[end][2]],
        [max_radius+nozzlegeom.thickness, -nozzlegeom.thickness],
        [0, -nozzlegeom.thickness]
    ]
end

profile_svg(noz::NozzleGeometry) = ConstructiveGeometry.svg("nozzle.svg", polygon(1000*generate_nozzle_contour(noz)))

function generate_solid(contour::Vector)
    return rotate_extrude() * ConstructiveGeometry.polygon(contour)
end

function add_connector_hole(solid, noz::NozzleGeometry, d::Float64)
    return solid \ ([0,0, -noz.thickness] + cylinder(noz.thickness, d/2))
end
#não gera um stl válido!!!
function add_stagnator(solid, noz::NozzleGeometry, radius_fraction::Float64, chamber_length_fraction::Float64)
    rc = get_radius(noz.areas.Achamber)
    union(solid,
        [0,0,noz.chamber_length*chamber_length_fraction] 
        + linear_extrude(noz.thickness) 
        * square(2*rc+eps(), 2*radius_fraction*rc, center=true)
    )
end

function export_stl(file::String, solid; rtol=1e-3, atol=1e-3)
    ConstructiveGeometry.stl(file, solid, rtol=rtol, atol=atol)
end

end
