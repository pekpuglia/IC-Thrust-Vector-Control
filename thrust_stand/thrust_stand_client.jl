using LibSerialPort
##
function send_command_data(sp::SerialPort, code::UInt8, data::Float32=Float32(0))
    write(sp, code, htol(data))
end
##
abstract type AbstractMenu end

##########################################################################################
#assume códigos para cada submenu na forma de um unsigned char, atribuido sequencialmente
struct ChoiceMenu <: AbstractMenu
    submenus::Vector{AbstractMenu}
    title::String
end

function title(cm::ChoiceMenu)
    join([cm.title*":", 
        "\t".*string.(1:length(cm.submenus)).*") ".*title.(cm.submenus)..., "Escolha um número (q para sair): "], "\n")
end

#opção p sair do menu?
function execute_menu(cm::ChoiceMenu, sp::SerialPort)
    while true
        print(title(cm))
        input = readline()
        if input == "q"
            return
        end
        index = try
            parse(Int, input)
        catch e
            if e isa ArgumentError
                println("input deve ser numérico")
                continue
            else
                throw(e)
            end
        end
        execute_menu(cm.submenus[index], sp)
    end
end
###############################################################################################
struct EmptyMenu <: AbstractMenu end
title(em::EmptyMenu) = "empty"
execute_menu(em::EmptyMenu, sp::SerialPort) = nothing
###############################################################################################
struct InputMenu <: AbstractMenu
    code::UInt8
    title::String
    prompt_text::String
end
title(im::InputMenu) = im.title

function execute_menu(im::InputMenu, sp::SerialPort)
    value = 0
    while true
        print(im.prompt_text)
        input = readline()
        try
            value = parse(Float32, input)
        catch e
            if e isa ArgumentError
                println("input deve ser numérico")
                continue
            else
                throw(e)
            end
        end
        #se obteve val com sucesso, pode encerrar
        break
    end
    if isnothing(sp)
        println("O valor é ", value)
    else
        send_command_data(sp, im.code, value)
    end
end
################################################################################
#adicionar armazenamento em vetor
#leitura de mais de uma variável/linha
struct OutputMenu <: AbstractMenu
    code::UInt8
    title::String
    number_of_outputs::Int
    data::Vector{Vector{Float32}}
    function OutputMenu(code::Integer, title::String, number_of_outputs::Int)
        new(code, title, number_of_outputs, [])
    end
end
title(om::OutputMenu) = om.title

function execute_menu(om::OutputMenu, sp::SerialPort)
    #input de n_reps
    n_reps = 0
    while true
        print("Repetições da medida: ")
        input = readline()
        try
            n_reps = parse(Int, input)
        catch e
            if e isa ArgumentError
                println("input deve ser numérico")
                continue
            else
                throw(e)
            end
        end
        #se obteve val com sucesso, pode encerrar
        break
    end
    empty!(om.data)
    for i in 1:n_reps
        send_command_data(sp, om.code)
        sleep(0.05)
        reading = readline(sp)
        println(reading)
        try

            push!(om.data, parse.(Float32, split(reading)))
        catch e
            if e isa ArgumentError
                continue
            end
        end
    end
end
####################################################################################
#
####################################################################################
struct CommandMenu <: AbstractMenu
    code::UInt8
    title::String
end
title(cm::CommandMenu) = cm.title
function execute_menu(cm::CommandMenu, sp::SerialPort)
    send_command_data(sp, cm.code)
end
##################################################################################
#fazer Configurable OutputMenu
#fstream Menu - salva saída em arquivo
main_menu = ChoiceMenu([InputMenu(0, "Calibrar balança", "Insira uma massa:"),
                        OutputMenu(1, "Exibir leitura da balança", 1),
                        CommandMenu(2, "Tarar a balança"),
                        OutputMenu(3, "Exibir leitura do termopar", 1),
                        OutputMenu(4, "Balança e termopar", 2),
    ], "ChoiceMenu")
##


LibSerialPort.open("/dev/ttyACM0", 9600) do sp
    execute_menu(main_menu, sp)
end
