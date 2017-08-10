module Java.Lang

import IdrisJvm.FFI

%access public export

namespace Boolean
  BooleanClass : JVM_NativeTy
  BooleanClass = Class "java/lang/Boolean"

  parseBool : String -> Bool
  parseBool s = unsafePerformIO $ invokeStatic BooleanClass "parseBoolean" (String -> JVM_IO Bool) s

namespace Byte
  ByteClass : JVM_NativeTy
  ByteClass = Class "java/lang/Byte"

  parseByte : String -> Bits8
  parseByte s = unsafePerformIO $ invokeStatic ByteClass "parseByte" (String -> JVM_IO Bits8) s

namespace Character
  CharacterClass : JVM_NativeTy
  CharacterClass = Class "java/lang/Character"

namespace JInteger
  IntegerClass : JVM_NativeTy
  IntegerClass = Class "java/lang/Integer"

  JInteger : Type
  JInteger = JVM_Native IntegerClass

  parseInt : String -> Int
  parseInt s = unsafePerformIO $ invokeStatic IntegerClass "parseInt" (String -> JVM_IO Int) s

  valueOf : Int -> JInteger
  valueOf n = unsafePerformIO $ invokeStatic IntegerClass "valueOf" (Int -> JVM_IO JInteger) n

namespace Short
  ShortClass : JVM_NativeTy
  ShortClass = Class "java/lang/Short"

  Short : Type
  Short = JVM_Native ShortClass

  parseShort : String -> Bits16
  parseShort s = unsafePerformIO $ invokeStatic ShortClass "parseShort" (String -> JVM_IO Bits16) s

  valueOf : Bits16 -> Short
  valueOf n = unsafePerformIO $ invokeStatic ShortClass "valueOf" (Bits16 -> JVM_IO Short) n

namespace Long
  LongClass : JVM_NativeTy
  LongClass = Class "java/lang/Long"

  Long : Type
  Long = JVM_Native LongClass

  parseLong : String -> Bits64
  parseLong s = unsafePerformIO $ invokeStatic LongClass "parseLong" (String -> JVM_IO Bits64) s

  valueOf : Bits64 -> Long
  valueOf n = unsafePerformIO $ invokeStatic LongClass "valueOf" (Bits64 -> JVM_IO Long) n

namespace JDouble
  DoubleClass : JVM_NativeTy
  DoubleClass = Class "java/lang/Double"

  JDouble : Type
  JDouble = JVM_Native DoubleClass

  parseDouble : String -> Double
  parseDouble s = unsafePerformIO $ invokeStatic DoubleClass "parseDouble" (String -> JVM_IO Double) s

  valueOf : Double -> JDouble
  valueOf n = unsafePerformIO $ invokeStatic DoubleClass "valueOf" (Double -> JVM_IO JDouble) n

namespace Math

  MathClass : JVM_NativeTy
  MathClass = Class "java/lang/Math"

  Math : Type
  Math = JVM_Native MathClass

  maxInt : Int -> Int -> Int
  maxInt a b = unsafePerformIO $ invokeStatic MathClass "max" (Int -> Int -> JVM_IO Int) a b

  maxDouble : Double -> Double -> Double
  maxDouble a b = unsafePerformIO $ invokeStatic MathClass "max" (Double -> Double -> JVM_IO Double) a b

  maxFloat : JFloat -> JFloat -> JFloat
  maxFloat a b = unsafePerformIO $ invokeStatic MathClass "max" (JFloat -> JFloat -> JVM_IO JFloat) a b

namespace Object
  ObjectClass : JVM_NativeTy
  ObjectClass = Class "java/lang/Object"

  Object : Type
  Object = JVM_Native ObjectClass

  ObjectArray : Type
  ObjectArray = JVM_Array ObjectClass

  ObjectArray2d : Type
  ObjectArray2d = JVM_Array (Array ObjectClass)

  toString : Object -> JVM_IO String
  toString obj = invokeInstance "toString" (Object -> JVM_IO String) obj

namespace PrintStream

  PrintStream : Type
  PrintStream = JVM_Native $ Class "java/io/PrintStream"

  println : PrintStream -> String -> JVM_IO ()
  println = invokeInstance "println" (PrintStream -> String -> JVM_IO ())

  printCh : PrintStream -> Char -> JVM_IO ()
  printCh = invokeInstance "print" (PrintStream -> Char -> JVM_IO ())

namespace System

  SystemClass : JVM_NativeTy
  SystemClass = Class "java/lang/System"

  getProperty : String -> JVM_IO (Maybe String)
  getProperty = invokeStatic SystemClass "getProperty" (String -> JVM_IO (Maybe String))

  getenv : String -> JVM_IO (Maybe String)
  getenv = invokeStatic SystemClass "getenv" (String -> JVM_IO (Maybe String))

  setProperty : String -> String -> JVM_IO (Maybe String)
  setProperty = invokeStatic SystemClass "setProperty" (String -> String -> JVM_IO (Maybe String))

  -- Takes a property name and a default value and returns the property value
  -- if it exists otherwise returns the default value
  getPropertyWithDefault : String -> String -> JVM_IO String
  getPropertyWithDefault = invokeStatic SystemClass "getProperty" (String -> String -> JVM_IO String)

  out : JVM_IO PrintStream
  out = getStaticField SystemClass "out" (JVM_IO PrintStream)

namespace Thread

  ThreadClass : JVM_NativeTy
  ThreadClass = Class "java/lang/Thread"

  Thread : Type
  Thread = JVM_Native ThreadClass

namespace JavaString

  StringClass : JVM_NativeTy
  StringClass = Class "java/lang/String"

  StringArray : Type
  StringArray = JVM_Array StringClass

  boolToString : Bool -> String
  boolToString b = unsafePerformIO $ invokeStatic StringClass "valueOf" (Bool -> JVM_IO String) b

  charAt : String -> Int -> Char
  charAt str index = unsafePerformIO $ invokeInstance "charAt" (String -> Int -> JVM_IO Char) str index

  charToString : Char -> String
  charToString b = unsafePerformIO $ invokeStatic StringClass "valueOf" (Char -> JVM_IO String) b

  byteToString : Bits8 -> String
  byteToString b = unsafePerformIO $ invokeStatic ByteClass "toString" (Bits8 -> JVM_IO String) b

  shortToString : Bits16 -> String
  shortToString b = unsafePerformIO $ invokeStatic ShortClass "toString" (Bits16 -> JVM_IO String) b

  longToString : Bits64 -> String
  longToString b = unsafePerformIO $ invokeStatic LongClass "toString" (Bits64 -> JVM_IO String) b

Inherits Object String where {}
Inherits Object (Maybe String) where {}

Inherits Object (JVM_Native t) where {}
Inherits Object (Maybe (JVM_Native t)) where {}

Inherits ObjectArray (JVM_Array (Class a)) where {}
Inherits ObjectArray (JVM_Array (Interface a)) where {}

