-- | This module provides the token type used in the lexer and
-- parser and provides the extra pass to insert layout tokens.
module Config.Tokens
  ( Token(..)
  , Located(..)
  , Position(..)
  , Error(..)
  , layoutPass
  ) where

import Data.Text (Text)

-- | A position in a text file
data Position = Position
  { posIndex, posLine, posColumn :: {-# UNPACK #-} !Int }
  deriving (Read, Show)

-- | A value annotated with its text file position
data Located a = Located
  { locPosition :: {-# UNPACK #-} !Position
  , locThing    :: !a
  }
  deriving (Read, Show)

instance Functor Located where
  fmap f (Located p x) = Located p (f x)

-- | The token type used by "Config.Lexer" and "Config.Parser"
data Token
  = Section Text
  | String Text
  | Atom Text
  | Bullet
  | Comma
  | Number Int Integer
  | OpenList
  | CloseList
  | OpenMap
  | CloseMap

  | Error Error

  -- "Virtual" tokens used by the subsequent layout processor
  | LayoutSep
  | LayoutEnd
  | EOF
  deriving (Show)

-- | Types of lexical errors
data Error
  = UntermComment
  | UntermCommentString
  | UntermString
  | UntermFile
  | BadEscape Text
  | NoMatch Char
  deriving (Show)

-- | Process a list of position-annotated tokens inserting
-- layout end tokens as appropriate.
layoutPass ::
  [Located Token] {- ^ tokens without layout markers -} ->
  [Located Token] {- ^ tokens with    layout markers -}
layoutPass toks = foldr step (\_ -> []) toks []

-- | Single step of the layout pass
step ::
  Located Token              {- ^ current token          -} ->
  ([Int] -> [Located Token]) {- ^ continuation           -} ->
  [Int]                      {- ^ stack of layout scopes -} ->
  [Located Token]            {- ^ token stream with layout -}

-- start blocks must be indented
-- tokens before the current layout end the current layout
-- note that EOF occurs on column 1 for properly formatted text files
step t next cols =
  case cols of
    col:_     | toCol t == col -> t{locThing=LayoutSep} : t : next cols
    col:cols' | toCol t <  col -> t{locThing=LayoutEnd} : step t next cols'
    _         | usesLayout t   -> t : next (toCol t : cols)
    _                          -> t : next cols

toCol :: Located a -> Int
toCol = posColumn . locPosition


-- | Return True when a token starts a layout scope.
usesLayout :: Located Token -> Bool
usesLayout t
  | Section{} <- locThing t = True
  | Bullet    <- locThing t = True
  | otherwise               = False
