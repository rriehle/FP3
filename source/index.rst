.. Lesson Plan documentation master file, created by
   sphinx-quickstart on Sun Jan 28 19:33:27 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

========================
Functional Programming 3
========================

.. toctree::
   :maxdepth: 2
   :caption: Contents:


************
Introduction
************

In this third lesson on functional programming follow a string of related techniques.  We first look at closures and compare them to classes and objects and thereby bridge the gap between functional programming and object oriented programming.  We then see how closures form the basis of function currying, and in turn how function currying facilitates functional composition.

We wrap up our series of functional programming lessons with an overview of the Itertools and Functools libraries which facilitate the techniques covered across all three lessons.

Recommended Text
================

For the functional programming modules, this lesson included, we recommend Functional Python Programming by Steven Lott.

| Publisher: Packt Publishing
| Pub. Date: January 31, 2015
| Web ISBN-13: 978-1-78439-761-6
| Print ISBN-13: 978-1-78439-699-2
| http://bit.ly/2azI62S

Each lesson's optional readings will draw from this text.

Learning Objectives
===================

Upon successful completion of this lesson, you will be able to:

* define a closure as a factory for creating stand-alone methods.
* describe the arity of a function.
* curry a function to reduce its arity, its number of arguments in particular, and thereby make it suitable for functional composition.
* use the Itertools library.
* use the Functools library.


New Words or Concepts
=====================

* Closure
* Scope
* Curry
* Arity
* Functional Composition
* Itertools
* Functools


Required Reading
================

* Functional Programming Modules

  | https://docs.python.org/3/library/functional.html

* Closures

  | `https://en.wikipedia.org/wiki/Closure_(computer_programming) <https://en.wikipedia.org/wiki/Closure_(computer_programming)>`_
  | http://wiki.c2.com/?ClosuresAndObjectsAreEquivalent

* Scope or *Lexical Scope* in Python

  | `https://en.wikipedia.org/wiki/Scope_(computer_science)#Python <https://en.wikipedia.org/wiki/Scope_(computer_science)#Python>`_

* Currying

  | https://en.wikipedia.org/wiki/Currying
  | https://en.wikipedia.org/wiki/Arity
  | `https://en.wikipedia.org/wiki/Function_composition_(computer_science) <https://en.wikipedia.org/wiki/Function_composition_(computer_science)>`_


Optional Reading
================

* Lott, S. (2015) Chapter 14. The PyMonad Library. Functional composition and currying. In Functional Python Programming.

* Lott, S. (2015) Chapter 8. The Itertools Module. In Functional Python Programming.

* Lott, S. (2015) Chapter 10. The Functools Module. In Functional Python Programming.

* What is the advantage of currying?

  | https://softwareengineering.stackexchange.com/questions/185585/what-is-the-advantage-of-currying

* FP is Dead, Long live FP
  | https://youtu.be/ROL58LJGNfA


*******
Content
*******

Closures
========

*The venerable master Qc Na was walking with his student, Anton. Hoping to prompt the master into a discussion, Anton said "Master, I have heard that objects (and classes) are a very good thing - is this true?" Qc Na looked pityingly at his student and replied, "Foolish pupil - objects are merely a poor man's closures."*

*Chastised, Anton took his leave from his master and returned to his cell, intent on studying closures. He carefully read the entire "Lambda: The Ultimate..." series of papers and its cousins, and implemented a small Scheme interpreter with a closure-based object system. He learned much, and looked forward to informing his master of his progress.*

*On his next walk with Qc Na, Anton attempted to impress his master by saying "Master, I have diligently studied the matter, and now understand that objects are truly a poor man's closures." Qc Na responded by hitting Anton with his stick, saying "When will you learn? Closures are a poor man's object." At that moment, Anton became enlightened.*

-- http://wiki.c2.com/?ClosuresAndObjectsAreEquivalent

What exactly are Closures, these mysterious things that offer programming enlightenment?  Before we consider a formal definition, let's continue to compare and contrast closures with objects.

* Objects have methods.
* Closures *are* methods --- they are defined and behave like functions, but like object methods they carry internal state and take it into account when returning results.

* Objects can, and generally do, carry mutable state.
* Closures can, and often do, carry mutable state.

* Objects control access to their attributes --- their internal state --- through Properties and Python's lexical scoping rules, by default however object attributes are externally accessible.
* Closures by nature tend to close around their internal state and thereby prevent external access, thus in terms of access to internal state, internal attributes, this is the opposite of the default behavior of an object.  In accordance with Python's Consenting Adults policy a closure's internal state is still accessible via its ``__closure__`` dunder, but this violates the spirit of a closure --- so do so at your own risk.

Thus, objects (or classes) and closures are similar, but different.

This is the general form of a closure:

.. code-block:: python

    def closure(internal_state):  # line 1
        def return_function(arguments):  # line 2
            return internal_state combined with arguments  # line 3
        return return_function  # line 4

Let's unpack that line by line.

1.  The closure is defined like any other function with a name and arguments.  In this case the name of the function is ``closure`` and its arguments are ``internal_state``.
2.  Inside the closure another function is defined.  It too takes arguments.  In this case its name is ``return_function``, because *this internally defined function itself will be returned by the closure.*
3.  When calculating a return value the internal function, ``return_function``, uses both the ``internal state`` passed into the closure on line 1 when the closure was first defined, and also the arguments that will be passed into it later when it is used as a stand-alone function.
4.  The closure uses the *internally defined* function, ``return_function`` for its return value.  **Thus, just as a class is a template or factory for creating objects, a closure is a template or factory for creating stand-alone methods.**


Functions Within Functions
--------------------------

We've been defining functions within functions to explore namespace scope.  But functions are "first class objects" in python, so we can not only define them and call them, but we can assign names to them and pass them around like any other object.

So after we define a function within a function, we can actually return that function as an object:

.. code-block:: python

    def counter(start_at=0):
        count = start_at
        def incr():
            nonlocal count
            count += 1
            return count
        return incr

So this looks a lot like the previous examples, but we are returning the function that was defined inside the function.

What's going on here?
.....................

We have passed the ``start_at`` value into the ``counter`` function.

We have stored it in ``counter``'s scope as a local variable: ``count``

Then we defined a function, ``incr`` that adds one to the value of count, and returns that value.

Note that we declared ``count`` to be nonlocal in ``incr``'s scope, so that it would be the same ``count`` that's in counter's scope.

What type of object do you get when you call ``counter()``?

.. code-block:: ipython

    In [37]: c = counter(start_at=5)

    In [38]: type(c)
    Out[38]: function

So we get a function back -- makes sense. The ``def`` defines a function, and that function is what's getting returned.

Being a function, we can, of course, call it:

.. code-block:: ipython

    In [39]: c()
    Out[39]: 6

    In [40]: c()
    Out[40]: 7

Each time is it called, it increments the value by one -- as you'd expect.

But what happens if we call ``counter()`` multiple times?

.. code-block:: ipython

    In [41]: c1 = counter(5)

    In [42]: c2 = counter(10)

    In [43]: c1()
    Out[43]: 6

    In [44]: c2()
    Out[44]: 11

So each time ``counter()`` is called, a new ``incr`` function is created. But also, a new namespace is created, that holds the count name. So the new ``incr`` function is holding a reference to that new count name.

This is what makes in a "closure" -- it carries with it the scope in which is was created.

The returned ``incr`` function is a "curried" function -- a function with some parameters pre-specified.

Let's experiment a bit more with these ideas:

:download:`play_with_scope.py <../examples/closures_currying/play_with_scope.py>`

.. :download:`capitalize.zip <../examples/packaging/capitalize.zip>`

Currying
========

"Currying" is a special case of closures:

The idea behind currying is that you may have a function with a number of parameters, and you want to make a specialized version that function with a couple parameters pre-set.


Real world Example
------------------

I was writing some code to compute the concentration of a contaminant in a river, as it was reduced by exponential decay, defined by a half-life:

https://en.wikipedia.org/wiki/Half-life

So I wanted a function that would compute how much the concentration would reduce as a function of time -- that is:

.. code-block:: python

    def scale(time):
        return scale_factor

The trick is, how much the concentration would be reduced depends on both time and the half life. And for a given material, and given flow conditions in the river, that half life is pre-determined.  Once you know the half-life, the scale is given by:

scale = 0.5 ** (time / (half_life))

So to compute the scale, I could pass that half-life in each time I called the function:

.. code-block:: python

    def scale(time, half_life):
        return 0.5 ** (time / (half_life))

But this is a bit klunky -- I need to keep passing that half_life around, even though it isn't changing. And there are places, like ``map`` that require a function that takes only one argument!

What if I could create a function, on the fly, that had a particular half-life "baked in"?

*Enter Currying* -- Currying is a technique where you reduce the number of parameters that function takes, creating a specialized function with one or more of the original parameters set to a particular value. Here is that technique, applied to the half-life decay problem:

.. code-block:: python

    def get_scale_fun(half_life):
        def half_life(time)
            return 0.5 ** (time / half_life)
        return half_life

**NOTE:** This is simple enough to use a lambda for a bit more compact code:

.. code-block:: python

    def get_scale_fun(half_life):
        return lambda time: 0.5 ** (time / half_life)

Using the Curried Function
..........................

Create a scale function with a half-life of one hour:

.. code-block:: ipython

    In [8]: scale = get_scale_fun(1)

    In [9]: [scale(t) for t in range(7)]
    Out[9]: [1.0, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625]

The value is reduced by half every hour.

Now create one with a half life of 2 hours:

.. code-block:: ipython

    In [10]: scale = get_scale_fun(2)

    In [11]: [scale(t) for t in range(7)]
    Out[11]:
    [1.0,
     0.7071067811865476,
     0.5,
     0.3535533905932738,
     0.25,
     0.1767766952966369,
     0.125]

And the value is reduced by half every two hours...

And it can be used with ``map``, too:

.. code-block:: ipython

    In [13]: list(map(scale, range(7)))
    Out[13]:
    [1.0,
     0.7071067811865476,
     0.5,
     0.3535533905932738,
     0.25,
     0.1767766952966369,
     0.125]


``functools.partial``
---------------------

The ``functools`` module in the standard library provides utilities for working with functions:

https://docs.python.org/3.5/library/functools.html

Creating a curried function turns out to be common enough that the ``functools.partial`` function provides an optimized way to do it:

What functools.partial does is:

 * Makes a new version of a function with one or more arguments already filled in.
 * The new version of a function documents itself.

Example:

.. code-block:: python

    def power(base, exponent):
        """returns based raised to the give exponent"""
        return base ** exponent

Simple enough. but what if we wanted a specialized ``square`` and ``cube`` function?

We can use ``functools.partial`` to *partially* evaluate the function, giving us a specialized version:

.. code-block:: python

    square = partial(power, exponent=2)
    cube = partial(power, exponent=3)



****
Quiz
****



********
Activity
********



**********
Assignment
**********



******************
Indices and tables
******************

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
