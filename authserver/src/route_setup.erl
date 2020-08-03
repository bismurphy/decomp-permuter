-module(route_setup).

-export([init/2]).

init(Req, Config) ->
    AuthSeed = enacl:randombytes(32),
    ClientSeed = enacl:randombytes(32),
    AuthPubKey = maps:get(public, enacl:sign_seed_keypair(AuthSeed)),
    ClientPubKey = maps:get(public, enacl:sign_seed_keypair(AuthSeed)),
    Output = [
        <<"Put the following in the auth server's priv.config:\n\n">>,
        <<"{priv_seed, ">>,
        io_lib:format("~p", [AuthSeed]),
        <<"}\n\n">>,
        <<"Once the server starts, run the following command in the Erlang shell:\n\n">>,
        <<"db:add_user(">>,
        io_lib:format("~p", [ClientPubKey]),
        <<", <<\"root\">>, <<>>)\n\n">>,
        <<"Put the following in the root client's pah.conf:\n\n">>,
        <<"secret_key = \"">>,
        to_hex(ClientSeed),
        <<"\"\n">>,
        <<"auth_server = \"https://server.example:port\"\n">>,
        <<"auth_public_key = \"">>,
        to_hex(AuthPubKey),
        <<"\"">>
    ],
    Req2 = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>},
        Output,
        Req
    ),
    {ok, Req2, Config}.

to_hex(Binary) ->
    [io_lib:format("~2.16.0b", [X]) || <<X:8>> <= Binary].
