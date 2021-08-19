using Genie
using Genie.Router
using HTTP
import Genie.Renderer.Json: json
using Genie.Renderer.Json, Genie.Requests

function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    route("/") do
        "Hi there! This is server 1"
    end
    
    route("/jsontest") do
        (:message => "Hi there!this is a json test") |> json
    end

    route("/echo", method = POST) do
        message = jsonpayload()
        (:echo => (message["message"] * " ")^message["repeat"]) |> json
    end

    route("/send") do
        response = HTTP.request(
            "POST",
            "https://julia-apiserver1.herokuapp.com/echo",
            [("Content-Type", "application/json")],
            """{"message":"hello", "repeat":3}""",
        )

        response.body |> String |> json
    end
    Genie.AppServer.startup(async = false)
end

launchServer(parse(Int, ARGS[1]))

