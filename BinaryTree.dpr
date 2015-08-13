program BinaryTree;

//Sample programm to demonstrate binary tree search by JurgisStepanovs, 2015
//Compiles with DelphiXE, modify for other Pascal distributions
//Input from ASCII file "IN_TEXT.TXT", must be manualy created in application start folder
//Note! This is NOT AVL-Tree demonstration, but realy fast enough on large texts

{$APPTYPE CONSOLE}

uses
  SysUtils;

type
//Pointer data structure that represents binary tree
  PNode = ^Tree;

//Additional data to each node in tree
  NodeData = record
   strWord: String;
   RepCount: Integer;
  end;

//tree data structure
  Tree = record
   key :  String;
   data : NodeData;
   left,right : PNode;
  end;

//global variables
var
 WordsTree: PNode;
 Ndata: NodeData;
 inF: TextFile;
 s: String;
 res: PNode;
 SearchStepCount: Integer;
 TotalWordsInText: Integer;

//New node setup
function NewNode(key: String; data: NodeData): PNode;
begin
  New(Result);
  Result.key := key;
  Result.data := data;
  Result.right := nil;
  Result.left  := nil;
end;

//Insert new node in tree
procedure InsertNode(node: PNode; key: String; data: NodeData);
begin
  if AnsiCompareStr(key,node.key)=0 then begin //if equal no add but count statistics
     Inc(node.data.RepCount);  //count the word repeating count
     Exit;
  end else
  if AnsiCompareStr(key,node.key)<0 then
    if Assigned(node.left) then
      InsertNode(node.left, key, data)
    else
      node.left := NewNode(key,data)
  else
    if Assigned(node.right) then
      InsertNode(node.right, key, data)
    else
      node.right := NewNode(key, data)
end;

//search in tree
function findInTree(node: PNode; key:String; var StepCount: Integer): PNode;
begin
      if node=nil then begin
        Result:=nil;
        Exit;
      end else
        if AnsiCompareStr(key,node.key)=0 then begin
            Inc(StepCount);
            Result:=node;
            Exit;
        end else begin
         Inc(StepCount);
         if AnsiCompareStr(key,node.key)<0 then
            Result := findInTree(node.left,key,StepCount)
          else Result := findInTree(node.right,key,StepCount);
        end;
end;

//Tree initialization procedure
procedure Add(var head: PNode; key: String; data: NodeData);
begin
  if Assigned(head) then
    InsertNode(head, key, data)
  else
    head := NewNode(key, data)
end;

//put a word in tree structure
procedure PutWordInTree(str: String);
var
  data: NodeData;
  m: Double;
begin
     data.strWord:=str;
     data.RepCount:=1;
     InsertNode(WordsTree,str,data);
end;

//process in text and split to words
procedure ProcessInText(str: String);
const
   termChars: set of Char = [' ',',','.','/','\','-',';',':','?','!','*','"','>','<','=','+','~','_','%','#','(',')','^','$','@'];
var i,L,m: Integer;
    tmp: String;
    f: Boolean;
begin
     tmp:='';
     str:=str+' ';
     L:=Length(str)-2;
     i:=1;
     f:=false;
     repeat
       tmp:=tmp+str[i];
       if (str[i+1] in termChars) or (i=L+1) then begin
        PutWordInTree(tmp);
        Inc(TotalWordsInText);
        tmp:='';
        f:=false;
        for m := i+1 to L do
         if not (str[m] in termChars) then begin
          i:=m;
          f:=true;
          break;
         end;
       end;
       if not f then i:=i+1 else f:=false;
     until i=L+2;
end;

//print out binary tree (in alphabetic order) with statistics about each word added!
procedure PrintTree(node: PNode);
begin
    if node<>nil then begin
       PrintTree(node.left);
       if node.key<>'mroot' then
        WriteLn(node.data.strWord,'=',node.data.RepCount);
       PrintTree(node.right);
    end;
end;

 //Main programm
begin

  TotalWordsInText:=0;

  WriteLn('**** Binary search tree demo by JurgisStepanovs 2015 ****');
  WriteLn('Reading text file "IN_TEXT.TXT" and putting words in binary tree ...');
  Add(WordsTree, 'mroot',Ndata);     //init B-tree with default root element
  AssignFile(inF,'IN_TEXT.TXT');
  reset(inF);
  while not eof(inF) do begin
   readln(inF, s);
   ProcessInText(s);
  end;
  CloseFile(inF);
  WriteLn('Binary tree created!');
  WriteLn('Text in file contains ',TotalWordsInText,' words.');
  WriteLn('Search for words and statistics by typing it ("q" to terminate, "p" to print tree):');
  repeat

    ReadLn(s);

    if (s='p') or (s='P') then  //print binary tree
     PrintTree(WordsTree)
    else if not((s='q') or (s='Q')) then begin //find specific word

     SearchStepCount:=0;

     res:=findInTree(WordsTree,s, SearchStepCount);

     if Assigned(res) then begin
      WriteLn('-------------------------------------------');
      WriteLn('Word found in ',SearchStepCount,' search steps.');
      WriteLn('Node.key='+res.key);
      WriteLn('Node.data.strWord='+res.data.strWord);
      WriteLn('Node.data.RepCount='+IntToStr(res.data.RepCount));
      WriteLn('-------------------------------------------');
     end else
       WriteLn('Word not found! Please try other search.');

    end;

  until (s='q') or (s='Q');


end.
