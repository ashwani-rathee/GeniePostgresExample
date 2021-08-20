using Genie
using Genie.Router
using HTTP
import Genie.Renderer.Json: json
using Genie.Renderer.Json, Genie.Requests
using LibPQ, Tables
conn = LibPQ.Connection("dbname=danenfcgd5khab host=ec2-35-153-114-74.compute-1.amazonaws.com port=5432 user=hbwwyuvguzemdw password=514ffbe17667034ddf0db74ae2d5157c2caf0374c5ac127d0ce38a679345786e sslmode=require")

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

    route("/create") do
        result = execute(conn, """       CREATE TABLE 'customers' (         'CustomerID' varchar(5) NOT NULL,
        'CompanyName' varchar(40) NOT NULL,
        'ContactName' varchar(30) DEFAULT NULL,
        PRIMARY KEY ('CustomerID'),
        KEY 'CompanyName' ('CompanyName'),)""")
    end

    route("/delete") do 
        result = execute(conn, """
        DROP TABLE IF EXISTS customers;
        """)
    end

    route("/adddata") do 
        result = execute(conn, """
        INSERT INTO customers VALUES ('ALFKI', 'Alfreds Futterkiste', 'Maria Anders', 'Sales Representative', 'Obere Str. 57', 'Berlin', NULL, '12209', 'Germany', '030-0074321', '030-0076545');
        INSERT INTO customers VALUES ('ANATR', 'Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'Owner', 'Avda. de la Constitución 2222', 'México D.F.', NULL, '05021', 'Mexico', '(5) 555-4729', '(5) 555-3745');
        INSERT INTO customers VALUES ('ANTON', 'Antonio Moreno Taquería', 'Antonio Moreno', 'Owner', 'Mataderos  2312', 'México D.F.', NULL, '05023', 'Mexico', '(5) 555-3932', NULL);
        INSERT INTO customers VALUES ('AROUT', 'Around the Horn', 'Thomas Hardy', 'Sales Representative', '120 Hanover Sq.', 'London', NULL, 'WA1 1DP', 'UK', '(171) 555-7788', '(171) 555-6750');
        INSERT INTO customers VALUES ('BERGS', 'Berglunds snabbköp', 'Christina Berglund', 'Order Administrator', 'Berguvsvägen  8', 'Luleå', NULL, 'S-958 22', 'Sweden', '0921-12 34 65', '0921-12 34 67');
        """)
    end
    Genie.AppServer.startup(async = false)
end

launchServer(parse(Int, ARGS[1]))

