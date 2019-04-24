#include <boost/python.hpp>

char const* greet(int x)
{
   return "hello, world";
}

BOOST_PYTHON_MODULE(testboost)
{
    using namespace boost::python;

    // Interestingly, the segfault goes away if we remove the default arg here (=0).
    // But that syntax isn't wrong.  It merely exposes the build problem.
    // (There are probably other ways to expose our build problems,
    // this is the first one I've found.)
    def("greet", greet, (arg("x")=0));
}
