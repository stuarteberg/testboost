#include <boost/python.hpp>

char const* greet(int x)
{
   return "hello, world";
}


//class C {
//public:
//    C(int x) {};
//};

BOOST_PYTHON_MODULE(testboost)
{
    using namespace boost::python;
    def("greet", greet, (arg("x")=0));

    //class_<C>("C", init<int>((arg("x"))));
}
