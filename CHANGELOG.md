0.4.0.2
----
* Internal lexer and parser improvements
* Added support for `\&` escape sequence

0.4.0.1
----
* Loosen version constraints to build back to GHC 7.4.2
* Remove unused bytestring dependency

0.4
----
* Make `Atom` a newtype to help distinguish it from `Text`
* Add `values` traversal for traversing individual elements of a list

0.3
-----
* Replace `yes` and `no` with generalized atoms
* Add character index to error position
* Add human readable error messages

0.2
-----
* Take `Text` as the input to `parse`

0.1.1
-----
* Added `Config.Lens` module
* Added aligned fields to pretty printer

0.1
-----
* Initial release
