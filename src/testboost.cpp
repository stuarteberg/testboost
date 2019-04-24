#include <boost/python.hpp>

char const* greet(int x)
{
   return "hello, world";
}

BOOST_PYTHON_MODULE(testboost)
{
    using namespace boost::python;
    def("greet", greet, (arg("x")=0));
}
