module CEAInterface
    using PyCall
    const CEA_OBJ = pyimport("rocketcea.cea_obj")
end