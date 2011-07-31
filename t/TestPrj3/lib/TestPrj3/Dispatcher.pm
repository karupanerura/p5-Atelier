package TestPrj3::Dispatcher;
use Atelier::Dispatcher::RouterSimple;

connect '/' => +{
    pages    => 'Root',
    dispatch => 'index',
};

connect '/echo/:text' => +{
    pages    => 'Root',
    dispatch => 'echo',
};

connect '/:dispatch/' => +{
    pages    => 'Root',
};

1;
