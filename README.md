# p5-MOP

This is the final prototype for adding a MOP (Meta Object Protocol) to Perl 5. 

... more details to come soon ...

## CONTRIBUTING

We are still in the early stages of this project, but any help would be much 
appreciated. Below lists some of the ways in which people can help out, with 
more ideas to come.

#### Tests, Tests and more Tests

If you look inside the individual test files there will often be a TODO list
at the top of them indicating aspects of the feature which need more testing. 

## INSTALLING DEPENDENCIES

Every effort has been made to reduce dependencies.

However, in the interest of avoiding having to write some C/XS before we are 
ready, we have opted to use some CPAN modules for the time being. The end 
goal is to have no dependencies, but for now just use the following command
to install our current set of dependencies.

```
cpanm --installdeps .
```

## COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Stevan Little.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

