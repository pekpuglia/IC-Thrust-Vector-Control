using LibSerialPort

abstract type AbstractMenu end

#assume códigos para cada submenu na forma de um unsigned char, atribuido sequencialmente
struct ChoiceMenu <: AbstractMenu
    submenus::Vector{AbstractMenu}
    title::String
end

function title(cm::ChoiceMenu)
    join([cm.title*":", 
        "\t".*string.(1:length(cm.submenus)).*") ".*title.(cm.submenus)..., "Escolha um numero: "], "\n")
end

#opção p sair do menu?
function execute_menu(cm::ChoiceMenu, sp::SerialPort=nothing)
    while true
        print(title(cm))
        input = readline()
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

struct EmptyMenu <: AbstractMenu end
title(em::EmptyMenu) = "empty"

struct InputMenu <: AbstractMenu
    code::UInt8
    title::String
    prompt_text::String
end
title(im::InputMenu) = im.title

function execute_menu(im::InputMenu, sp::SerialPort=nothing)
    local value::Float32
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
        write(sp, im.code, htol(value))
    end
end

#fazer OutputMenu, etc
main_menu = ChoiceMenu([InputMenu(0, "Calibrar balança", "Insira uma massa:"),
                        ], "ChoiceMenu")
##
LibSerialPort.open("/dev/ttyACM0", 9600) do sp
    execute_menu(main_menu, sp)
end
