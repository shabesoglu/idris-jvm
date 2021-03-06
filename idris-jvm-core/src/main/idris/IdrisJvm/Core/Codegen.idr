module IdrisJvm.Core.Codegen

import IdrisJvm.IO
import IdrisJvm.Core.Asm
import IdrisJvm.IR.Types
import IdrisJvm.Core.Common
import IdrisJvm.Core.Constant
import IdrisJvm.Core.Function
import IdrisJvm.Core.JAsm
import IdrisJvm.IR.Exports

%access public export

generateDependencyMethods : Assembler -> List (Asm ()) -> JVM_IO ()
generateDependencyMethods assembler [] = pure ()
generateDependencyMethods assembler (subroutine :: subroutines) = do
  (_, newSubroutines) <- runAsm [] assembler subroutine
  generateDependencyMethods assembler (newSubroutines ++ subroutines)

generateMethod' : Assembler -> SDecl -> JVM_IO ()
generateMethod' assembler (SFun name args _ def) = do
  let jmethodName = jname name
  let fname = jmethName jmethodName
  let clsName = jmethClsName jmethodName
  (_, subroutines) <- runAsm [] assembler $ cgFun [Public, Static] name clsName fname args def
  generateDependencyMethods assembler subroutines

generateMethod : Assembler -> SDecl -> JVM_IO ()
generateMethod assembler decl@(SFun "{APPLY_0}" _ _ _) = do
      _ <- sequence $ generateMethod' assembler <$> splitApplyFunction decl
      pure ()
  where
    group : Nat -> List a -> List (List a)
    group _ [] = []
    group n xs =
        let (ys, zs) = splitAt n xs
        in  ys :: group n zs

    callNextFn : String -> List String -> Int -> LVar -> Nat -> (Nat, List SAlt) -> SDecl
    callNextFn fname args n caseVar last (index, cs) = SFun currFn args n body where
      nextFn : String
      nextFn = fname ++ "$" ++ show (index + 1)

      currFn : String
      currFn = if index == 0 then fname else (fname ++ "$" ++ show index)

      body = SChkCase caseVar $ if index + 1 == last then cs else (cs ++ [SDefaultCase (SApp True nextFn [Loc 0, Loc 1])])

    splitApplyFunction : SDecl -> List SDecl
    splitApplyFunction (SFun fname args n (SChkCase var cases)) =
      map (callNextFn fname args n var len) . List.zip [0.. len] $ cs where
        cs = group 100 cases
        len = List.length cs

generateMethod assembler decl = generateMethod' assembler decl

generateExport : Assembler -> ExportIFace -> JVM_IO ()
generateExport assembler exportIFace = do
  (_, _) <- runAsm [] assembler $ exportCode exportIFace
  pure ()

exports : FFI_Export FFI_JVM "idrisjvm/core/JCodegen" []
exports =
  Data SDecl "idrisjvm/ir/SDecl" $
  Data FDesc "idrisjvm/ir/FDesc" $
  Data SExp "idrisjvm/ir/SExp" $
  Data Const "idrisjvm/ir/Const" $
  Data LVar "idrisjvm/ir/LVar" $
  Data CaseType "idrisjvm/ir/CaseType" $
  Data Export "idrisjvm/ir/Export" $
  Data NativeTy "idrisjvm/ir/NativeTy" $
  Data ExportIFace "idrisjvm/ir/ExportIFace" $
  Data IntTy ("idrisjvm/ir/IntTy") $
  Data ArithTy ("idrisjvm/ir/ArithTy") $
  Data PrimFn ("idrisjvm/ir/PrimFn") $
  Data SAlt "idrisjvm/ir/SAlt" $
  Data (FDesc, LVar) "idrisjvm/ir/SForeignArg" $
  Data (List SAlt) "idris/prelude/list/ListSAlt" $
  Data (List (FDesc, LVar)) "idrisjvm/ir/SForeignArgs" $
  Data (Maybe LVar) "idrisjvm/ir/MaybeLVar" $
  Data (List String) "idris/prelude/list/ListString" $
  Data (List FDesc) "idris/prelude/list/ListFDesc" $
  Data (List LVar) "idris/prelude/list/ListLVar" $
  Data (List Export) "idris/prelude/list/ListExport" $

  Fun consFDesc (ExportStatic "consFDesc") $
  Fun emptyFDesc (ExportStatic "emptyFDesc") $

  Fun consString (ExportStatic "consString") $
  Fun emptyListString (ExportStatic "emptyListString") $

  Fun fcon (ExportStatic "fcon") $
  Fun fstr (ExportStatic "fstr") $
  Fun fapp (ExportStatic "fapp") $
  Fun fio (ExportStatic "fio") $
  Fun funknown (ExportStatic "funknown") $

  Fun loc (ExportStatic "loc") $
  Fun glob (ExportStatic "glob") $

  Fun consLVar (ExportStatic "consLVar") $
  Fun emptyLVar (ExportStatic "emptyLVar") $

  Fun consExport (ExportStatic "consExport") $
  Fun emptyExport (ExportStatic "emptyExport") $
  Fun exportData (ExportStatic "exportData") $
  Fun Exports.exportFun (ExportStatic "exportFun") $

  Fun mkExportIFace (ExportStatic "mkExportIFace") $

  Fun it8 (ExportStatic "it8") $
  Fun it16 (ExportStatic "it16") $
  Fun it32 (ExportStatic "it32") $
  Fun it64 (ExportStatic "it64") $

  Fun itFixed (ExportStatic "itFixed") $
  Fun itNative (ExportStatic "itNative") $
  Fun itBig (ExportStatic "itBig") $
  Fun itChar (ExportStatic "itChar") $

  Fun atInt (ExportStatic "atInt") $
  Fun atFloat (ExportStatic "atFloat") $

  Fun lFExp (ExportStatic "lFExp") $
  Fun lFLog (ExportStatic "lFLog") $
  Fun lFSin (ExportStatic "lFSin") $
  Fun lFCos (ExportStatic "lFCos") $
  Fun lFTan (ExportStatic "lFTan") $
  Fun lFASin (ExportStatic "lFASin") $
  Fun lFACos (ExportStatic "lFACos") $
  Fun lFATan (ExportStatic "lFATan") $
  Fun lFSqrt (ExportStatic "lFSqrt") $
  Fun lFFloor (ExportStatic "lFFloor") $
  Fun lFCeil (ExportStatic "lFCeil") $
  Fun lFNegate (ExportStatic "lFNegate") $
  Fun lStrHead (ExportStatic "lStrHead") $
  Fun lStrTail (ExportStatic "lStrTail") $
  Fun lStrCons (ExportStatic "lStrCons") $
  Fun lStrIndex (ExportStatic "lStrIndex") $
  Fun lStrRev (ExportStatic "lStrRev") $
  Fun lStrSubstr (ExportStatic "lStrSubstr") $
  Fun lReadStr (ExportStatic "lReadStr") $
  Fun lWriteStr (ExportStatic "lWriteStr") $
  Fun lSystemInfo (ExportStatic "lSystemInfo") $
  Fun lFork (ExportStatic "lFork") $
  Fun lPar (ExportStatic "lPar") $
  Fun lCrash (ExportStatic "lCrash") $
  Fun lNoOp (ExportStatic "lNoOp") $
  Fun lStrConcat (ExportStatic "lStrConcat") $
  Fun lStrLt (ExportStatic "lStrLt") $
  Fun lStrEq (ExportStatic "lStrEq") $
  Fun lStrLen (ExportStatic "lStrLen") $
  Fun lFloatStr (ExportStatic "lFloatStr") $
  Fun lStrFloat (ExportStatic "lStrFloat") $
  Fun lPlus (ExportStatic "lPlus") $
  Fun lMinus (ExportStatic "lMinus") $
  Fun lTimes (ExportStatic "lTimes") $
  Fun lSDiv (ExportStatic "lSDiv") $
  Fun lSRem (ExportStatic "lSRem") $
  Fun lEq (ExportStatic "lEq") $
  Fun lSLt (ExportStatic "lSLt") $
  Fun lSLe (ExportStatic "lSLe") $
  Fun lSGt (ExportStatic "lSGt") $
  Fun lSGe (ExportStatic "lSGe") $
  Fun lUDiv (ExportStatic "lUDiv") $
  Fun lURem (ExportStatic "lURem") $
  Fun lAnd (ExportStatic "lAnd") $
  Fun lOr (ExportStatic "lOr") $
  Fun lXOr (ExportStatic "lXOr") $
  Fun lCompl (ExportStatic "lCompl") $
  Fun lSHL (ExportStatic "lSHL") $
  Fun lLSHR (ExportStatic "lLSHR") $
  Fun lASHR (ExportStatic "lASHR") $
  Fun lLt (ExportStatic "lLt") $
  Fun lLe (ExportStatic "lLe") $
  Fun lGt (ExportStatic "lGt") $
  Fun lGe (ExportStatic "lGe") $
  Fun lIntFloat (ExportStatic "lIntFloat") $
  Fun lFloatInt (ExportStatic "lFloatInt") $
  Fun lIntStr (ExportStatic "lIntStr") $
  Fun lStrInt (ExportStatic "lStrInt") $
  Fun lChInt (ExportStatic "lChInt") $
  Fun lIntCh (ExportStatic "lIntCh") $
  Fun lSExt (ExportStatic "lSExt") $
  Fun lZExt (ExportStatic "lZExt") $
  Fun lTrunc (ExportStatic "lTrunc") $
  Fun lBitCast (ExportStatic "lBitCast") $
  Fun lExternal (ExportStatic "lExternal") $

  Fun sConCase (ExportStatic "sConCase") $
  Fun sConstCase (ExportStatic "sConstCase") $
  Fun sDefaultCase (ExportStatic "sDefaultCase") $
  Fun consSAlt (ExportStatic "consSAlt") $
  Fun emptySAlt (ExportStatic "emptySAlt") $

  Fun mkSForeignArg (ExportStatic "mkSForeignArg") $

  Fun consSForeignArg (ExportStatic "consSForeignArg") $
  Fun emptySForeignArg (ExportStatic "emptySForeignArg") $

  Fun nothingLVar (ExportStatic "nothingLVar") $
  Fun justLVar (ExportStatic "justLVar") $

  Fun constI (ExportStatic "constI") $
  Fun constBI (ExportStatic "constBI") $
  Fun constFl (ExportStatic "constFl") $
  Fun constCh (ExportStatic "constCh") $
  Fun constStr (ExportStatic "constStr") $
  Fun constB8 (ExportStatic "constB8") $
  Fun constB16 (ExportStatic "constB16") $
  Fun constB32 (ExportStatic "constB32") $
  Fun constB64 (ExportStatic "constB64") $
  Fun aType (ExportStatic "aType") $
  Fun strType (ExportStatic "strType") $
  Fun worldType (ExportStatic "worldType") $
  Fun theWorld (ExportStatic "theWorld") $
  Fun voidType (ExportStatic "voidType") $
  Fun forgot (ExportStatic "forgot") $

  Fun sV (ExportStatic "sV") $
  Fun sApp (ExportStatic "sApp") $
  Fun sLet (ExportStatic "sLet") $
  Fun sUpdate (ExportStatic "sUpdate") $
  Fun sCon (ExportStatic "sCon") $
  Fun sCase (ExportStatic "sCase") $
  Fun sChkCase (ExportStatic "sChkCase") $
  Fun sProj (ExportStatic "sProj") $
  Fun sConst (ExportStatic "sConst") $
  Fun sForeign (ExportStatic "sForeign") $
  Fun sOp (ExportStatic "sOp") $
  Fun sNothing (ExportStatic "sNothing") $
  Fun sError (ExportStatic "sError") $

  Fun sFun (ExportStatic "sFun") $

  Fun updatable (ExportStatic "updatable") $
  Fun shared (ExportStatic "shared") $

  Fun generateMethod (ExportStatic "generateMethod") $
  Fun generateExport (ExportStatic "generateExport") $
  End


