using LibSerialPort
##
LibSerialPort.open("/dev/ttyACM0", 9600) do sp
    while true
        input = readline()
        if input == "q"
            return
        end
        int_to_send = try
            parse(Int32, input)
        catch e
            if e isa ArgumentError
                println("input deve ser numérico")
                continue
            else
                throw(e)
            end
        end
        write(sp, htol(int_to_send), '\n')
    end
end