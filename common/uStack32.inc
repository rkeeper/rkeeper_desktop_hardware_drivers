asm
  mov EAX,ESP
  add EAX,20
  mov EAX,[EAX]
  mov ExcEBP,EAX
end;
