dnl Copyright 2002, The libsigc++ Development Team 
dnl 
dnl This library is free software; you can redistribute it and/or 
dnl modify it under the terms of the GNU Lesser General Public 
dnl License as published by the Free Software Foundation; either 
dnl version 2.1 of the License, or (at your option) any later version. 
dnl 
dnl This library is distributed in the hope that it will be useful, 
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of 
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
dnl Lesser General Public License for more details. 
dnl 
dnl You should have received a copy of the GNU Lesser General Public 
dnl License along with this library; if not, write to the Free Software 
dnl Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
dnl
divert(-1)
include(template.macros.m4)

dnl 
dnl Macros to make operators
define([LAMBDA_OPERATOR_DO],[dnl
  template <LOOP(class T_arg%1, $1)>
  typename deduce_result_type<LOOP(T_arg%1,$1)>::type
  operator ()(LOOP(T_arg%1 _A_%1, $1)) const
    {
      return lambda_action<T_action>::template do_action<
            typename deduce_result_type<LOOP(T_arg%1,$1)>::left_type,
            typename deduce_result_type<LOOP(T_arg%1,$1)>::right_type>
        (arg1_.template operator()<LOOP(_P_(T_arg%1), $1)>
            (LOOP(_A_%1, $1)),
         arg2_.template operator()<LOOP(_P_(T_arg%1), $1)>
            (LOOP(_A_%1, $1)));
    }

])
define([LAMBDA_OPERATOR_UNARY_DO],[dnl
  template <LOOP(class T_arg%1, $1)>
  typename deduce_result_type<LOOP(T_arg%1,$1)>::type
  operator ()(LOOP(T_arg%1 _A_%1, $1)) const
    {
      return lambda_action_unary<T_action>::template do_action<
            typename deduce_result_type<LOOP(T_arg%1,$1)>::operand_type>
        (arg_.template operator()<LOOP(_P_(T_arg%1), $1)>
            (LOOP(_A_%1, $1)));
    }

])
define([LAMBDA_OPERATOR],[dnl
dnl TODO: check for this compiler bug and consequectly don't use typeof() if compiler is buggy:
dnl       typeof() ignores "&"
dnl       (http://gcc.gnu.org/cgi-bin/gnatsweb.pl?cmd=view%20audit-trail&database=gcc&pr=10243)
dnl       E.g. typeof(type_trait<std::ostream&>::instance() << type_trait<int>::instance())
dnl                 == std::ostream  //(instead of std::ostream&)
#ifdef SIGC_CXX_TYPEOF
template <class T_test1, class T_test2>
struct lambda_action_deduce_result_type<$1, T_test1, T_test2>
  { typedef typeof(type_trait<T_test1>::instance() $2 type_trait<T_test2>::instance()) type; };
#endif
divert(1)dnl
template <>
struct lambda_action<$1 >
{
  template <class T_arg1, class T_arg2>
  static typename lambda_action_deduce_result_type<$1, T_arg1, T_arg2>::type
  do_action(T_arg1 _A_1, T_arg2 _A_2)
    { return _A_1 $2 _A_2; }
};

divert(2)dnl
// operators for $1
template <class T_arg1, class T_arg2>
lambda<lambda_operator<$1, T_arg1, T_arg2> >
operator $2 (const lambda<T_arg1>& a1, const lambda<T_arg2>& a2)
{ return lambda<lambda_operator<$1, T_arg1, T_arg2> >(lambda_operator<$1, T_arg1, T_arg2>(a1.value_,a2.value_)); }
template <class T_arg1, class T_arg2>
lambda<lambda_operator<$1, T_arg1, T_arg2> >
operator $2 (const lambda<T_arg1>& a1, T_arg2 a2)
{ return lambda<lambda_operator<$1, T_arg1, T_arg2> >(lambda_operator<$1, T_arg1, T_arg2>(a1.value_,a2)); }
template <class T_arg1, class T_arg2>
lambda<lambda_operator<$1, T_arg1, T_arg2> >
operator $2 (T_arg1 a1, const lambda<T_arg2>& a2)
{ return lambda<lambda_operator<$1, T_arg1, T_arg2> >(lambda_operator<$1, T_arg1, T_arg2>(a1,a2.value_)); }

divert(0)dnl
])
define([LAMBDA_OPERATOR_UNARY],[dnl
dnl TODO: check for this compiler bug and consequectly don't use typeof() if compiler is buggy:
dnl       typeof() ignores "&"
dnl       (http://gcc.gnu.org/cgi-bin/gnatsweb.pl?cmd=view%20audit-trail&database=gcc&pr=10243)
dnl       E.g. typeof(type_trait<std::ostream&>::instance() << type_trait<int>::instance())
dnl                 == std::ostream  //(instead of std::ostream&)
#ifdef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<$1, T_test>
  { typedef typeof($2 type_trait<T_test>::instance()) type; };
#endif
divert(1)dnl
template <>
struct lambda_action_unary<$1 >
{
  template <class T_arg>
  static typename lambda_action_unary_deduce_result_type<$1, T_arg>::type
  do_action(T_arg _A)
    { return $2 _A; }
};

divert(2)dnl
// operator for $1
template <class T_arg>
lambda<lambda_operator_unary<$1, T_arg> >
operator $2 (const lambda<T_arg>& a)
{ return lambda<lambda_operator_unary<$1, T_arg> >(lambda_operator_unary<$1, T_arg>(a.value_)); }

divert(0)dnl
])
divert(0)dnl
#ifndef _SIGC_LAMBDA_OPERATOR_HPP_
#define _SIGC_LAMBDA_OPERATOR_HPP_
#include <sigc++/adaptors/lambda/base.h>

namespace sigc {
namespace functor {

template <class T_type>
struct arithmetic {};

template <class T_type>
struct bitwise {};

template <class T_type>
struct logical {};

template <class T_type>
struct relational {};

template <class T_type>
struct arithmetic_assign {};

template <class T_type>
struct bitwise_assign {};

template <class T_type>
struct other {};

template <class T_type>
struct unary_arithmetic {};

template <class T_type>
struct unary_bitwise {};

template <class T_type>
struct unary_logical {};

template <class T_type>
struct unary_other {};

struct plus {};
struct minus {};
struct multiply {};
struct divide {};
struct remainder {};
struct leftshift {};
struct rightshift {};
struct and_ {};
struct or_ {};
struct xor_ {};
struct less {};
struct greater {};
struct lessorequal {};
struct greaterorequal {};
struct equal {};
struct notequal {};
struct assign {};
struct preincrement {};
struct predecrement {};
struct not_ {};
struct address {};
struct dereference {};

template <class T_action, class T_test1, class T_test2>
struct lambda_action_deduce_result_type
  { typedef typename type_trait<T_test1>::type type; }; // TODO: e.g. T_test1=int, T_test2=double yields int but it should yield double !

#ifdef SIGC_CXX_TYPEOF
template <class T_action, class T_test1>
struct lambda_action_deduce_result_type<T_action, T_test1, void>
  { typedef void type; };
template <class T_action, T_test2>
struct lambda_action_deduce_result_type<T_action, void, T_test2>
  { typedef void type; };
template <class T_action>
struct lambda_action_deduce_result_type<T_action, void, void>
  { typedef void type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_action, class T_test1, class T_test2>
struct lambda_action_deduce_result_type<logical<T_action>, T_test1, T_test2>
  { typedef bool type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_action, class T_test1, class T_test2>
struct lambda_action_deduce_result_type<relational<T_action>, T_test1, T_test2>
  { typedef bool type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_action, class T_test1, class T_test2>
struct lambda_action_deduce_result_type<arithmetic_assign<T_action>, T_test1, T_test2>
  { typedef T_test1 type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_action, class T_test1, class T_test2>
struct lambda_action_deduce_result_type<bitwise_assign<T_action>, T_test1, T_test2>
  { typedef T_test1 type; };
#endif

template <class T_action, class T_test>
struct lambda_action_unary_deduce_result_type
  { typedef typename type_trait<T_test>::type type; };

#ifdef SIGC_CXX_TYPEOF
template <class T_action>
struct lambda_action_unary_deduce_result_type<T_action, void>
  { typedef void type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_action, class T_test>
struct lambda_action_unary_deduce_result_type<unary_logical<T_action>, T_test>
  { typedef bool type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<unary_other<address>, T_test>
  { typedef typename type_trait<T_test>::pointer type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<unary_other<dereference>, T_test>
  { typedef void type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<unary_other<dereference>, T_test*>
  { typedef typename type_trait<T_test>::pass type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<unary_other<dereference>, const T_test*>
  { typedef typename type_trait<const T_test>::pass type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<unary_other<dereference>, T_test*&>
  { typedef typename type_trait<T_test>::pass type; };
#endif

#ifndef SIGC_CXX_TYPEOF
template <class T_test>
struct lambda_action_unary_deduce_result_type<unary_other<dereference>, const T_test*&>
  { typedef typename type_trait<const T_test>::pass type; };
#endif

LAMBDA_OPERATOR(arithmetic<plus>,+)
LAMBDA_OPERATOR(arithmetic<minus>,-)
LAMBDA_OPERATOR(arithmetic<multiply>,*)
LAMBDA_OPERATOR(arithmetic<divide>,/)
LAMBDA_OPERATOR(arithmetic<remainder>,%)
LAMBDA_OPERATOR(bitwise<leftshift>,<<)
LAMBDA_OPERATOR(bitwise<rightshift>,>>)
LAMBDA_OPERATOR(bitwise<and_>,&)
LAMBDA_OPERATOR(bitwise<or_>,|)
LAMBDA_OPERATOR(bitwise<xor_>,^)
LAMBDA_OPERATOR(logical<and_>,&&)
LAMBDA_OPERATOR(logical<or_>,||)
LAMBDA_OPERATOR(relational<less>,<)
LAMBDA_OPERATOR(relational<greater>,>)
LAMBDA_OPERATOR(relational<lessorequal>,<=)
LAMBDA_OPERATOR(relational<greaterorequal>,>=)
LAMBDA_OPERATOR(relational<equal>,==)
LAMBDA_OPERATOR(relational<notequal>,!=)
LAMBDA_OPERATOR(arithmetic_assign<plus>,+=)
LAMBDA_OPERATOR(arithmetic_assign<minus>,-=)
LAMBDA_OPERATOR(arithmetic_assign<multiply>,*=)
LAMBDA_OPERATOR(arithmetic_assign<divide>,/=)
LAMBDA_OPERATOR(arithmetic_assign<remainder>,%=)
LAMBDA_OPERATOR(bitwise_assign<leftshift>,<<=)
LAMBDA_OPERATOR(bitwise_assign<rightshift>,>>=)
LAMBDA_OPERATOR(bitwise_assign<and_>,&=)
LAMBDA_OPERATOR(bitwise_assign<or_>,|=)
LAMBDA_OPERATOR(bitwise_assign<xor_>,^=)
LAMBDA_OPERATOR_UNARY(unary_arithmetic<preincrement>,++)
LAMBDA_OPERATOR_UNARY(unary_arithmetic<predecrement>,--)
LAMBDA_OPERATOR_UNARY(unary_bitwise<not_>,~)
LAMBDA_OPERATOR_UNARY(unary_logical<not_>,!)
LAMBDA_OPERATOR_UNARY(unary_other<address>,&)
LAMBDA_OPERATOR_UNARY(unary_other<dereference>,*)

template <class T_action>
struct lambda_action {};

template <class T_action>
struct lambda_action_unary {};

undivert(1)dnl

template <class T_action, class T_type1, class T_type2>
struct lambda_operator : public lambda_base
{
  typedef typename lambda<T_type1>::lambda_type arg1_type;
  typedef typename lambda<T_type2>::lambda_type arg2_type;

  template <LOOP(class T_arg%1=void,CALL_SIZE)>
  struct deduce_result_type
    { typedef typename arg1_type::deduce_result_type<LOOP(_P_(T_arg%1),CALL_SIZE)>::type left_type;
      typedef typename arg2_type::deduce_result_type<LOOP(_P_(T_arg%1),CALL_SIZE)>::type right_type;
      typedef typename lambda_action_deduce_result_type<T_action, left_type, right_type>::type type;
    };
  typedef typename lambda_action_deduce_result_type<
      T_action,
      typename arg1_type::result_type,
      typename arg2_type::result_type
    >::type result_type;

  result_type
  operator ()() const;

FOR(1, CALL_SIZE,[[LAMBDA_OPERATOR_DO]](%1))dnl
  lambda_operator(_R_(T_type1) a1, _R_(T_type2) a2 )
    : arg1_(a1), arg2_(a2) {}

  arg1_type arg1_;
  arg2_type arg2_;
};

template <class T_action, class T_type1, class T_type2>
typename lambda_operator<T_action, T_type1, T_type2>::result_type
lambda_operator<T_action, T_type1, T_type2>::operator ()() const
  { return lambda_action<T_action>::template do_action<
      typename arg1_type::result_type,
      typename arg2_type::result_type>
      (arg1_(), arg2_()); }

template <class T_action, class T_lambda_action, class T_arg1, class T_arg2>
void visit_each(const T_action& _A_action,
                const lambda_operator<T_lambda_action, T_arg1, T_arg2>& _A_target)
{
  visit_each(_A_action, _A_target.arg1_);
  visit_each(_A_action, _A_target.arg2_);
}


template <class T_action, class T_type>
struct lambda_operator_unary : public lambda_base
{
  typedef typename lambda<T_type>::lambda_type arg_type;

  template <LOOP(class T_arg%1=void,CALL_SIZE)>
  struct deduce_result_type
    { typedef typename arg_type::deduce_result_type<LOOP(_P_(T_arg%1),CALL_SIZE)>::type operand_type;
      typedef typename lambda_action_unary_deduce_result_type<T_action, operand_type>::type type;
    };
  typedef typename lambda_action_unary_deduce_result_type<
      T_action,
      typename arg_type::result_type
    >::type result_type;

  result_type
  operator ()() const;

FOR(1, CALL_SIZE,[[LAMBDA_OPERATOR_UNARY_DO]](%1))dnl
  lambda_operator_unary(_R_(T_type) a)
    : arg_(a) {}

  arg_type arg_;
};

template <class T_action, class T_type>
typename lambda_operator_unary<T_action, T_type>::result_type
lambda_operator_unary<T_action, T_type>::operator ()() const
  { return lambda_action_unary<T_action>::template do_action<
      typename arg_type::result_type>
      (arg_()); }

template <class T_action, class T_lambda_action, class T_arg>
void visit_each(const T_action& _A_action,
                const lambda_operator_unary<T_lambda_action, T_arg>& _A_target)
{
  visit_each(_A_action, _A_target.arg_);
}


undivert(2)dnl

} /* namespace functor */
} /* namespace sigc */

#endif /* _SIGC_LAMBDA_OPERATOR_HPP_ */
