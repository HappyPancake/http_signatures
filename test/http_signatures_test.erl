-module(http_signatures_test).

-include_lib("eunit/include/eunit.hrl").

-define(RSA_KEY,<<"Test">>).

rsa_sha_test() ->
  AResponse = get_fixture("example_response.txt"),
  PemBin = get_fixture("test.pem"),

  application:start(crypto),
  application:start(asn1),
  application:start(http_signatures),
  
  ok = http_signatures:register_key(?RSA_KEY, sha256, PemBin),

  ?assertNot(http_signatures:is_signed_response(AResponse)),

  SignedResponse = http_signatures:get_signed_response(AResponse, ?RSA_KEY),

  ?assert(http_signatures:is_signed_response(SignedResponse)),
  
  AlteredResponse = replace_something_in_signature(SignedResponse),

  ?assertNot(http_signatures:is_signed_response(AlteredResponse)).


get_fixture(FileName) ->
  {ok, Content} = file:read_file("../priv/fixtures/"++FileName),
  Content.

replace_something_in_signature(Response) ->
  {Pos,Length} = binary:match(Response,<<",signature=\"">>), 
  ToReplace=binary:part(Response,{Pos+Length+10,10}),
  binary:replace(Response, ToReplace,<<"0123456789">>).



