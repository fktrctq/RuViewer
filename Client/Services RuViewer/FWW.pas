unit FWW;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls,VCL.Forms, Vcl.Dialogs, Vcl.StdCtrls,ActiveX,  ComObj,inifiles;




    function AddLANRule(NameRule,DescriptRule,RuleGrouping:string;ProtocolInt,ProtocolPort:integer;EnablDsbl:boolean):boolean; // ��������� ������� ��� ����
    function AddApplicationRule(port:integer;path,RuleGrouping,RuleName:string):boolean;  // ��������� ������� ��� ����������
    function CheckingRuleEnabled(nameRule:string):bool; //�������� �� �������
    function EnumerateFirewallRules(RuleGrouping,RuleName:string):bool; // ����� ������� �� �����  ������
    function RestrictService(ServiceName,ApplicationName,RuleName,RuleGrouping,RemoteIP:string;LocalPorts,Protocol,InOut:integer):bool;
    function AddIPForRules(Grouping,IP:string):bool; //���������� ip � ������ ������
    function EnableRuleGroups(RuleNameGroup:string;Enable:bool):bool; // ��������� ������ ������
    procedure StartFW;
 const
 //Profile Type
 NET_FW_PROFILE2_DOMAIN = 1;
 NET_FW_PROFILE2_PRIVATE = 2;
 NET_FW_PROFILE2_PUBLIC = 4;
//Protocol
 NET_FW_IP_PROTOCOL_TCP = 6 ;
NET_FW_IP_PROTOCOL_UDP = 17;
NET_FW_IP_PROTOCOL_ICMPv4 = 1 ;
 NET_FW_IP_PROTOCOL_ICMPv6 = 58 ;
//Direction
NET_FW_RULE_DIR_IN = 1;
NET_FW_RULE_DIR_OUT = 2;
// Action
NET_FW_ACTION_BLOCK = 0;
NET_FW_ACTION_ALLOW = 1;

implementation

function Log_write(fname, text:string):string;
var f:TStringList;
begin
  //if not DirectoryExists(ExtractFilePath(Application.ExeName)+'logs') then
  // CreateDir(ExtractFilePath(Application.ExeName)+'logs');
  f:=TStringList.Create;
  try
    if FileExists(ExtractFilePath(Application.ExeName)+fname+'.log') then
      f.LoadFromFile(ExtractFilePath(Application.ExeName)+fname+'.log');
    f.Insert(0,DateTimeToStr(Now)+chr(9)+text);
    while f.Count>1000 do f.Delete(1000);
    f.SaveToFile(ExtractFilePath(Application.ExeName)+fname+'.log');
  finally
    f.Destroy;
  end;
end;

procedure Code(var text: Widestring; password: WideString;   //// �������� ���������� ������ ��� ������
decode: boolean);
var
i, PasswordLength: integer;
sign: shortint;
begin
PasswordLength := length(password);
if PasswordLength = 0 then Exit;
if decode
then sign := -1
else sign := 1;
for i := 1 to Length(text) do
text[i] := chr(ord(text[i]) + sign *
ord(password[i mod PasswordLength + 1]));
end;


//���� ��� ��������� ������� ��������� ���� ��� �����, ��������� API ����������� Microsoft Windows.
function AddLANRule(NameRule,DescriptRule,RuleGrouping:string;ProtocolInt,ProtocolPort:integer;EnablDsbl:boolean):boolean;
var
 CurrentProfiles : OleVariant;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
 NewRule         : OleVariant;
begin
try
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes; // ������� ������� �������
  //Create a Rule Object.
  NewRule := CreateOleObject('HNetCfg.FWRule');   // ������� ����� �������
  NewRule.Name := NameRule;
  NewRule.Description := DescriptRule;
  NewRule.Protocol := protocolInt;//NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts := ProtocolPort;
  NewRule.Interfacetypes := 'LAN';
  NewRule.Enabled := EnablDsbl;
  NewRule.Grouping := RuleGrouping;
  NewRule.Profiles := CurrentProfiles;
  NewRule.Action := NET_FW_ACTION_ALLOW;
  //Add a new rule
  RulesObject.Add(NewRule);
  result:=true;
finally
VariantClear( NewRule);
VariantClear(CurrentProfiles);
VariantClear(RulesObject);
VariantClear(fwPolicy2);
end;
end;

// ������� ��� ���������
function AddApplicationRule(port:integer;path,RuleGrouping,RuleName:string):boolean; // �������� ����� ����� � ���� �� �����
var
 CurrentProfiles : OleVariant;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
 NewRule         : OleVariant;
begin
try
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;
  //Create a Rule Object.
  NewRule := CreateOleObject('HNetCfg.FWRule');
  NewRule.Name := RuleName;
  NewRule.Description := '�������� ������ ��� ���������� uRDMServer.exe';
  NewRule.Applicationname := path;//'C:\Program Files (x86)\uRDMServer\uRDMServer.exe';
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  //NewRule.LocalPorts := port;
  NewRule.Enabled := True;
  NewRule.Grouping := RuleGrouping;
  NewRule.Profiles := CurrentProfiles;
  NewRule.Action := NET_FW_ACTION_ALLOW;
  //Add a new rule
  RulesObject.Add(NewRule);
 finally
  VariantClear(NewRule);
  VariantClear(CurrentProfiles);
  VariantClear(RulesObject);
  VariantClear(fwPolicy2);
 end;
end;

function CheckingRuleEnabled(nameRule:string):bool; // �������� �� �������
Const
 NET_FW_MODIFY_STATE_OK = 0;
 NET_FW_MODIFY_STATE_GP_OVERRIDE = 1;
 NET_FW_MODIFY_STATE_INBOUND_BLOCKED = 2;
var
 fwPolicy2         : OleVariant;
 PolicyModifyState : Integer;
begin
try
result:=false;
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  result:= fwPolicy2.IsRuleGroupCurrentlyEnabled(nameRule);//��� ��� ������ "���� ������ �� ������" //'File and Printer Sharing'  //�������� ������ ������ ������ ������ ������ � ������ � ��������� � ������� ��������
  PolicyModifyState := fwPolicy2.LocalPolicyModifyState;
  case PolicyModifyState of
    NET_FW_MODIFY_STATE_OK             : Log_write('FW','��������� ��� ���������� ������� ����������� (��� ������) ������� � ���� ��� ������� ��� ������ �� ������� ��������..');
    NET_FW_MODIFY_STATE_GP_OVERRIDE    : Log_write('FW','��������� ��� ���������� ������� ����������� (��� ������) � ������� �������� �� ������� � ����, ������ ��� ��������� �������� �������������� ��� �� ������� ���� �� ����� �� ������� ��������.');
    NET_FW_MODIFY_STATE_INBOUND_BLOCKED: Log_write('FW','��������� ��� ���������� ������� (��� ������) ��������� ����������� � ������� �������� �� ������� � ����, ��������� �������� ������� �� ��������� ���� �� ��� ������ �� ������� ��������.')
    else
    Log_write('FW','�������� ��������� ���������, ������������ LocalPolicyModifyState.');
  End;
 variantclear(fwPolicy2);
except
    on E:EOleException do
        Log_write('FW',Format('������ ������ �������', [E.Message,E.ErrorCode]));
    on E:Exception do
        Log_write('FW','������ ������ �������'+ E.Classname+ ':'+ E.Message);
 end;
end;

function EnumerateFirewallRules(RuleGrouping,RuleName:string):bool; // ����� ������� �� ������ � �����
Const
  NET_FW_PROFILE2_DOMAIN  = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC  = 4;

  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_IP_PROTOCOL_UDP = 17;
  NET_FW_IP_PROTOCOL_ICMPv4 = 1;
  NET_FW_IP_PROTOCOL_ICMPv6 = 58;

  NET_FW_RULE_DIR_IN = 1;
  NET_FW_RULE_DIR_OUT = 2;

  NET_FW_ACTION_BLOCK = 0;
  NET_FW_ACTION_ALLOW = 1;

var
 CurrentProfiles : Integer;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
 rule            : OleVariant;
 oEnum           : IEnumvariant;
 iValue          : LongWord;
begin
try
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;
  result:=false;
 { if (CurrentProfiles AND NET_FW_PROFILE2_DOMAIN)<>0 then
     Log_write('FW','Domain Firewall Profile is active');

  if ( CurrentProfiles AND NET_FW_PROFILE2_PRIVATE )<>0 then
      Log_write('FW','Private Firewall Profile is active');

  if ( CurrentProfiles AND NET_FW_PROFILE2_PUBLIC )<>0 then
      Log_write('FW','Public Firewall Profile is active');}

  oEnum         := IUnknown(Rulesobject._NewEnum) as IEnumVariant;
  while oEnum.Next(1, rule, iValue) = 0 do
  begin
    if (rule.Grouping = RuleGrouping)and(rule.Name=RuleName) and(rule.Profiles=CurrentProfiles) then
    begin //���� ��� �������, ������ ������� � ������� ���� ������� ���������, �� ������� ��������� �� ����
    result:=true;
       Log_write('FW','--------------------------------Rule exist-----------------------------------------');
       Log_write('FW','  Rule Name:          ' + rule.Name);
       Log_write('FW','  Description:        ' + rule.Description);
       Log_write('FW','  Application Name:   ' + rule.ApplicationName);
       Log_write('FW','  Service Name:       ' + rule.ServiceName);
      {  Case rule.Protocol of
           NET_FW_IP_PROTOCOL_TCP    : Log_write('FW','  IP Protocol:        TCP.');
           NET_FW_IP_PROTOCOL_UDP    : Log_write('FW','  IP Protocol:        UDP.');
           NET_FW_IP_PROTOCOL_ICMPv4 : Log_write('FW','  IP Protocol:        UDP.');
           NET_FW_IP_PROTOCOL_ICMPv6 : Log_write('FW','  IP Protocol:        UDP.');
        Else                           Log_write('FW','  IP Protocol:        ' + VarToStr(rule.Protocol));
        End; }
        if (rule.Protocol = NET_FW_IP_PROTOCOL_TCP) or (rule.Protocol = NET_FW_IP_PROTOCOL_UDP) then
        begin
          Log_write('FW','  Local Ports:        ' + rule.LocalPorts);
          Log_write('FW','  Remote Ports:       ' + rule.RemotePorts);
          Log_write('FW','  LocalAddresses:     ' + rule.LocalAddresses);
          Log_write('FW','  RemoteAddresses:    ' + rule.RemoteAddresses);
        end;
        {Case rule.Direction of
            NET_FW_RULE_DIR_IN :  Log_write('FW','  Direction:          In');
            NET_FW_RULE_DIR_OUT:  Log_write('FW','  Direction:          Out');
        End;
       Log_write('FW','  Enabled:            ' + VarToStr(rule.Enabled));
       Log_write('FW','  Edge:               ' + VarToStr(rule.EdgeTraversal));
        Case rule.Action of
           NET_FW_ACTION_ALLOW : Log_write('FW','  Action:             Allow');
           NET_FW_ACTION_BLOCk : Log_write('FW','  Action:             Block');
        End;
        Log_write('FW','  Grouping:           ' + rule.Grouping);
        Log_write('FW','  Edge:               ' + VarToStr(rule.EdgeTraversal));
        Log_write('FW','  Interface Types:    ' + rule.InterfaceTypes);}
    end;
    rule:=Unassigned;
  end;
finally
 oEnum:=nil;
 VariantClear(rule);
 VariantClear(RulesObject);
 VariantClear(fwPolicy2);
end;

end;


function RestrictService(ServiceName,ApplicationName,RuleName,RuleGrouping,RemoteIP:string;
LocalPorts,Protocol,InOut:integer):bool; /// �������� ������� ��� �����
var     //���� ������� ��� �������
 fwPolicy2       : OleVariant;
 wshRules        : OleVariant;
 ServiceRestriction, NewInboundRule, NewOutboundRule,RulesObject : OleVariant;
 CurrentProfiles : OleVariant;
begin
try
result:=false;
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  CurrentProfiles := fwPolicy2.CurrentProfileTypes; // ������� ������� ����
  RulesObject := fwPolicy2.Rules;
  if (InOut=1) or (InOut=3) then // 1 -�������� 2- ��������� 3 - �������� � ���������
  begin
  NewInboundRule := CreateOleObject('HNetCfg.FWRule');
  NewInboundRule.Name := RuleName;//'Allow only TCP 3389 inbound to service';
  NewInboundRule.Grouping:=RuleGrouping;
  NewInboundRule.ApplicationName := ApplicationName;//'%systemDrive%\WINDOWS\system32\svchost.exe';
  if ServiceName<>'' then NewInboundRule.ServiceName := ServiceName;//'TermService';
  NewInboundRule.Protocol := Protocol;// NET_FW_IP_PROTOCOL_TCP; //6
  if LocalPorts<>0 then NewInboundRule.LocalPorts := LocalPorts;//3389;
  NewInboundRule.RemoteAddresses:=RemoteIP;
  NewInboundRule.Profiles := CurrentProfiles;

  NewInboundRule.Action := NET_FW_ACTION_ALLOW;
  NewInboundRule.Direction := NET_FW_RULE_DIR_IN;
  NewInboundRule.Enabled := True;

  RulesObject.Add(NewInboundRule);
  end;
  if (InOut=2) or (InOut=3) then // 1 -�������� 2- ��������� 3 - �������� � ���������
  begin
  //Add outbound WSH allow rules ��������� ���������
  NewOutboundRule := CreateOleObject('HNetCfg.FWRule');
  NewOutboundRule.Name := RuleName;//'Allow outbound traffic from service only from TCP 3389';
  NewOutboundRule.Grouping:= RuleGrouping;
  NewOutboundRule.ApplicationName :=ApplicationName; //'%systemDrive%\WINDOWS\system32\svchost.exe';
  NewOutboundRule.ServiceName := ServiceName;//'TermService';
  NewOutboundRule.Protocol := Protocol;// NET_FW_IP_PROTOCOL_TCP;
  if LocalPorts<>0 then NewInboundRule.LocalPorts := LocalPorts;//3389;
  NewOutboundRule.Profiles := CurrentProfiles;
  NewOutboundRule.Action := NET_FW_ACTION_ALLOW;
  NewOutboundRule.Direction := NET_FW_RULE_DIR_OUT;
  NewOutboundRule.Enabled := True;
  RulesObject.Add(NewOutboundRule);
  end;

  result:=true;
finally
  VariantClear(NewInboundRule);
  VariantClear(NewOutboundRule);
  VariantClear(wshRules);
  VariantClear(ServiceRestriction);
  VariantClear(fwPolicy2);
end;
end;

function AddIPForRules(Grouping,IP:string):bool; // ���������� IP ������� ��� ������
Const
  NET_FW_PROFILE2_DOMAIN  = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC  = 4;

  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_IP_PROTOCOL_UDP = 17;
  NET_FW_IP_PROTOCOL_ICMPv4 = 1;
  NET_FW_IP_PROTOCOL_ICMPv6 = 58;

  NET_FW_RULE_DIR_IN = 1;
  NET_FW_RULE_DIR_OUT = 2;

  NET_FW_ACTION_BLOCK = 0;
  NET_FW_ACTION_ALLOW = 1;

var
 CurrentProfiles : Integer;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
 rule            : OleVariant;
 oEnum           : IEnumvariant;
 iValue          : LongWord;
begin
try
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;
  result:=false;
   oEnum         := IUnknown(Rulesobject._NewEnum) as IEnumVariant;
  while oEnum.Next(1, rule, iValue) = 0 do
  begin
   if (AnsiPos(AnsiLowerCase(Grouping),AnsiLowerCase(rule.Name))<>0) then
       begin

       if (rule.Protocol = NET_FW_IP_PROTOCOL_TCP) or (rule.Protocol = NET_FW_IP_PROTOCOL_UDP) then
        begin
          rule.RemoteAddresses:=IP;
          Log_write('FW','---------------------------------Add Remote IP Addresses--------------------------------------');
          Log_write('FW','  Rule Name:          ' + rule.Name);
          Log_write('FW','  RemoteAddresses:    ' + rule.RemoteAddresses);
          result:=true;
        end;

    end;
    rule:=Unassigned;
  end;
finally
 oEnum:=nil;
 VariantClear(rule);
 VariantClear(RulesObject);
 VariantClear(fwPolicy2);
end;
end;
//���������/���������� ������ ������.
function EnableRuleGroups(RuleNameGroup:string;Enable:bool):bool;
var
 CurrentProfiles : Integer;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
begin
try
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;
  fwPolicy2.EnableRuleGroup(CurrentProfiles,RuleNameGroup,Enable); //������� �������, ��� ������ ������, �������� ��� ���������
except
    on E:EOleException do
    begin
        Log_write('FW','������ ���������/���������� ������ ������');
        Log_write('FW',Format(booltostr(Enable)+' / EOleException %s %x', [E.Message,E.ErrorCode]));
    end;
    on E:Exception do
        Log_write('FW',booltostr(Enable)+ ' / '+E.Classname+ ':'+ E.Message);
 end;
 end;

function ReadKey(Section,Key:string):string;
var
mylist,mylist2:tstringList;
Mini: TMemIniFile;
b:integer;
s:widestring;
begin
   mylist:=Tstringlist.Create;
    mylist2:=Tstringlist.Create;
    Mini:=TMemIniFile.Create(ChangeFileExt( Application.Exename,'.ini'));
    try
        begin
        mylist.LoadFromFile(ExtractFilePath(Application.ExeName) + 'client.dat',TEncoding.Unicode);
           for b := 0 to mylist.Count-1 do
               begin
                s:=mylist[b];
                code(s, '12345', true);
                mylist2.Add(s);
                end;
               Mini.SetStrings(mylist2);
        end;
    result:=Mini.Readstring(Section,Key,'');
    finally
    mylist.Free;
    mylist2.Free;
    Mini.Free
    end;
end;

function ReadFW(Section,Key:string):bool;
var
mylist,mylist2:tstringList;
Mini: TMemIniFile;
b:integer;
s:widestring;
begin
   mylist:=Tstringlist.Create;
    mylist2:=Tstringlist.Create;
    Mini:=TMemIniFile.Create(ChangeFileExt( Application.Exename,'.ini'));
    try
        begin
        mylist.LoadFromFile(ExtractFilePath(Application.ExeName) + 'client.dat',TEncoding.Unicode);
           for b := 0 to mylist.Count-1 do
               begin
                s:=mylist[b];
                code(s, '12345', true);
                mylist2.Add(s);
                end;
               Mini.SetStrings(mylist2);
        end;
    result:=Mini.ReadBool(Section,Key,true);
    Log_write('FW',Section+'/'+Key+' - '+BoolToStr(result));
    finally
    mylist.Free;
    mylist2.Free;
    Mini.Free
    end;
end;


procedure StartFW;
begin
try
    CoInitialize(nil);
    try

      if ReadFW( 'FW','RuViewer') then  // ������ � �����, �������� ��� ��� ������� � fireFall
      if not EnumerateFirewallRules('RuViewer','RuViewer') then  // ���� ��� ������� ��� ���������� �� �������   // uRDMServer
       begin
       if ReadKey('Server','Port')<>'' then // ������ ���� �� ������� �������� ���������
       AddApplicationRule(strtoint(ReadKey('Server','Port')),'C:\Program Files (x86)\MRSD\RuViewer.exe','RuViewer','RuViewer');
       end;

      {if ReadFW('FW','FullFW') then///////////////////////////////��������� ����������� ������� ��� �����
      begin
      if not EnumerateFirewallRules('MRPC','MRPC in DCOM WMI') then
      RestrictService('RPCSS','%systemDrive%\WINDOWS\system32\svchost.exe', 'MRPC in DCOM WMI', 'MRPC',ReadKey('Server','IP'),135,NET_FW_IP_PROTOCOL_TCP,1);
      if not EnumerateFirewallRules('MRPC','MRPC in winmgmt') then
      RestrictService('winmgmt','%systemDrive%\WINDOWS\system32\svchost.exe', 'MRPC in winmgmt', 'MRPC',ReadKey('Server','IP'),0,NET_FW_IP_PROTOCOL_TCP,1);
      if not EnumerateFirewallRules('MRPC','MRPC out winmgmt') then
      RestrictService('winmgmt','%systemDrive%\WINDOWS\system32\svchost.exe', 'MRPC out winmgmt', 'MRPC',ReadKey('Server','IP'),0,NET_FW_IP_PROTOCOL_TCP,2);
      if not EnumerateFirewallRules('MRPC','MRPC in unsecapp') then
      RestrictService('','%systemDrive%\WINDOWS\system32\unsecapp.exe', 'MRPC in unsecapp', 'MRPC',ReadKey('Server','IP'),0,NET_FW_IP_PROTOCOL_TCP,1);

      if not EnumerateFirewallRules('MRPC','MRPC in TCP RPC-EPMAP') then
      RestrictService('RPCSS','%systemDrive%\WINDOWS\system32\svchost.exe', 'MRPC in TCP RPC-EPMAP', 'MRPC',ReadKey('Server','IP'),0,NET_FW_IP_PROTOCOL_TCP,1);
      if not EnumerateFirewallRules('MRPC','MRPC in RPC') then
      RestrictService('ktmrm','%systemDrive%\WINDOWS\system32\svchost.exe', 'MRPC in RPC', 'MRPC',ReadKey('Server','IP'),0,NET_FW_IP_PROTOCOL_TCP,1);
      if not EnumerateFirewallRules('MRPC','MRPC in RPC TCP') then
      RestrictService('','%systemDrive%\WINDOWS\system32\msdtc.exe','MRPC in RPC TCP','MRPC',ReadKey('Server','IP'),135,NET_FW_IP_PROTOCOL_TCP,1);

      if not EnumerateFirewallRules('MRPC','MRPC TCP RDP') then
      RestrictService('TermService','%systemDrive%\WINDOWS\system32\svchost.exe','MRPC TCP RDP','MRPC',ReadKey('Server','IP'),3389,NET_FW_IP_PROTOCOL_TCP,1);
      if not EnumerateFirewallRules('MRPC','MRPC UDP RDP') then
      RestrictService('TermService','%systemDrive%\WINDOWS\system32\svchost.exe','MRPC UDP RDP','MRPC',ReadKey('Server','IP'),3389,NET_FW_IP_PROTOCOL_UDP,1);
      if not EnumerateFirewallRules('MRPC','MRPC RDPSa') then
      RestrictService('','%systemDrive%\WINDOWS\system32\RdpSa.exe','MRPC RDPSa','MRPC',ReadKey('Server','IP'),0,NET_FW_IP_PROTOCOL_TCP,1);
      EnableRuleGroups('MRPC',true);  // �������� ������ ������, ����� ��� ���������
      end
      else EnableRuleGroups('MRPC',false);} // ����� ��������� ������ ������

     { if ReadFW('FW','FilePrintSh') then
      begin
      EnableRuleGroups('File and Printer Sharing',true); // ��������� ������ ������  //Windows Management Instrumentation,Remote Desktop ,File and Printer Sharing
      EnableRuleGroups('����� ������ � ������ � ���������',true);      //FilePrintSh
      AddIPForRules('����� ������ � ������ � ���������',ReadKey('Server','IP')); //
      AddIPForRules('File and Printer Sharing',ReadKey('Server','IP'));
      end;
      if ReadFW('FW','RDP') then
      begin
      EnableRuleGroups('Remote Desktop',true);                         //RDP
      EnableRuleGroups('������������� ���������� ������� ������',true); //RDP // ��������� ����� ������ ������
      AddIPForRules('��������� ������� ����',ReadKey('Server','IP')); // ��������� � �������� IP �����
      AddIPForRules('Remote Desktop',ReadKey('Server','IP'));
      end;
      if ReadFW('FW','WMI') then
      begin
      EnableRuleGroups('Windows Management Instrumentation',true);  //WMI
      EnableRuleGroups('�������������� ���������� Windows (WMI)',true); //WMI  // ��������� ����� ������ ������
      AddIPForRules('�������������� ���������� Windows',ReadKey('Server','IP'));  // ��������� � �������� IP �����
      AddIPForRules('Windows Management Instrumentation',ReadKey('Server','IP'));
      end;
      if ReadFW('FW','RPC') then
      begin
      EnableRuleGroups('Distributed Transaction Coordinator',true); //RPC
      EnableRuleGroups('����������� �������������� ����������',true);  //RPC
      AddIPForRules('����������� �������������� ����������',ReadKey('Server','IP'));
      AddIPForRules('Distributed Transaction Coordinator',ReadKey('Server','IP'));
      end;}
    finally
      CoUninitialize;
    end;
 except
    on E:EOleException do
    begin
    Log_write('FW','����� ������ ��������� ������');
    Log_write('FW',Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    end;
    on E:Exception do Log_write('FW',E.Classname+ ':'+ E.Message);
 end;
end;

end.
