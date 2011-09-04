package TestPrj3::Dispatcher;
use Atelier::Dispatcher::RouterSimple;

any '/' => +{
    pages    => 'Root',
    dispatch => 'index',
};

get '/echo/:text' => +{
    pages    => 'Root',
    dispatch => 'echo',
};

post '/:dispatch/' => +{
    pages    => 'Root',
};

1;
