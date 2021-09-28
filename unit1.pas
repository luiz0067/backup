unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  MaskEdit, Calendar, ExtCtrls, Buttons,FileUtil;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOrigem: TButton;
    ButtonDestino: TButton;
    ButtonOk: TButton;
    ButtonRemoverUsuariosDaLista: TButton;
    ButtonRemoverTentarNovamente: TButton;
    CalendarData: TCalendar;
    EditLocal: TEdit;
    EditLocalOrigem: TEdit;
    EditLocalDestino: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    LabelPastaBackup: TLabel;
    ListBoxArquivosCopiado: TListBox;
    ListBoxArquivosErros: TListBox;
    ListBoxUsuarios: TListBox;
    ListBoxArquivosASeremCopiados: TListBox;
    MaskEditPatrimoneo: TMaskEdit;
    ProgressBarProgresso: TProgressBar;
    SelectDirectoryDialogDestino: TSelectDirectoryDialog;
    SelectDirectoryDialogOrigem: TSelectDirectoryDialog;

    procedure ButtonRemoverTentarNovamenteClick(Sender: TObject);
    procedure ButtonRemoverUsuariosDaListaClick(Sender: TObject);
    procedure ButtonDestinoClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonOrigemClick(Sender: TObject);
    procedure CalendarDataChange(Sender: TObject);
    procedure EditLocalChange(Sender: TObject);
    procedure EditLocalDestinoChange(Sender: TObject);
    procedure EditLocalOrigemChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxUsuariosSelectionChange(Sender: TObject; User: boolean);
    procedure MaskEditPatrimoneoChange(Sender: TObject);
  private

  public
    procedure calculaPastaBackup();
    procedure Backup();
    function valida_usuarios_tecnicos(usuario:string):boolean;
    function valida_usuarios_padrao(usuario:string):boolean;
  end;

type

{ TMyThread }

  TMyThread = class(TThread)
  private
    fStatusText: string;
    procedure Progresso(position:integer);
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
  end;
const pastas:array [1..8] of String=(
  'Desktop',
  'Documents',
  'Downloads',
  'Favorites',
  'Music',
  'OneDrive',
  'Pictures',
  'Videos'
  );

const usuarios_tecnicos:array [1..4] of String=(
  'tecnico1.informatica',
  'tecnico2.informatica',
  'tecnico3.informatica',
  'tecnico4.informatica'
  );

  const usuarios_padrao:array [1..6] of String=(
  'Administrador',
  'Public',
  'Todos os Usuários',
  'Default',
  'DefaultAppPool',
  'Usuário Padrão'
  );


var
  Form1: TForm1;
  MyThread:TMyThread;
  PastaOrigem:String;
  PastaDestino:String;
  usuarios:TStrings;
  pastaBackup:String;
implementation

{$R *.lfm}

{ TMyThread }

procedure TMyThread.Progresso(position:integer);
begin
  Form1.ProgressBarProgresso.Position:=position;
  if(position>=100)
  ShowMessage('Arquivos copiados com sucesso!');
end;

procedure TMyThread.Execute;
begin
  Form1.Backup();
end;

constructor TMyThread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;


{ TForm1 }




procedure TForm1.ListBoxUsuariosSelectionChange(Sender: TObject; User: boolean);
begin
 usuarios:=ListBoxArquivosASeremCopiados.Items;
end;

procedure TForm1.MaskEditPatrimoneoChange(Sender: TObject);
begin
  calculaPastaBackup;
end;

procedure TForm1.EditLocalChange(Sender: TObject);
begin
  calculaPastaBackup;
end;

procedure TForm1.EditLocalDestinoChange(Sender: TObject);
begin
  calculaPastaBackup;
end;

procedure TForm1.EditLocalOrigemChange(Sender: TObject);
begin
  calculaPastaBackup;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  vDate : TDateTime;
begin
  PastaOrigem:='';
  PastaDestino:='';
  vDate := Date();
  CalendarData.DateTime:=vDate;
  calculaPastaBackup;

end;



procedure TForm1.CalendarDataChange(Sender: TObject);
begin
  calculaPastaBackup;
end;

procedure TForm1.ButtonOkClick(Sender: TObject);
begin
  MyThread:=TMyThread.Create(false);
  MyThread.Execute();
end;

procedure TForm1.ButtonDestinoClick(Sender: TObject);
begin
  if SelectDirectoryDialogDestino.Execute then
 begin
    pastaDestino:=SelectDirectoryDialogDestino.FileName;
    EditLocalDestino.Text:=pastaDestino;
 end;
end;

procedure TForm1.ButtonRemoverUsuariosDaListaClick(Sender: TObject);
begin
   ListBoxUsuarios.DeleteSelected;
end;

procedure TForm1.ButtonRemoverTentarNovamenteClick(Sender: TObject);
begin
  ListBoxArquivosASeremCopiados.Items:=ListBoxArquivosErros.Items;
  Backup();
end;

procedure TForm1.ButtonOrigemClick(Sender: TObject);
var
  j:integer;
  usuario:string ;
  usuarios_temp:TStrings;
begin
 if SelectDirectoryDialogOrigem.Execute then
 begin
    pastaOrigem:=SelectDirectoryDialogOrigem.FileName;
    EditLocalOrigem.Text:=pastaOrigem;
    usuarios:=FindAllDirectories(PastaOrigem, false);
    usuarios_temp:=TStringList.Create;
    for j:=0 to usuarios.Count-1 do
    begin
      usuario:=usuarios[j]  ;
      usuario:=copy(usuario, Length(PastaOrigem)+2,Length(usuario) - (Length(PastaOrigem)+1));
      if (usuario.IndexOf('.') <>0) then   //não começa com . mas tem .
      //if (not valida_usuarios_tecnicos(usuario)) then   //sem tecnicos.
      if (not valida_usuarios_padrao(usuario)) then   //sem usuarios padrão.
      begin
        usuarios_temp.Add(usuario);
        ListBoxUsuarios.Items.add(usuario);
      end;
    end;
    usuarios.Clear;
    usuarios:=usuarios_temp;
    ListBoxArquivosASeremCopiados.Items.Clear;
 end;
end;

procedure TForm1.calculaPastaBackup();
begin
  pastaBackup:='Backup '+EditLocal.Text+' PC'+MaskEditPatrimoneo.text+' '+StringReplace(DATETOSTR(CalendarData.DateTime),'/','-',[rfReplaceAll, rfIgnoreCase]);
  LabelPastaBackup.Caption:=pastaBackup;
end;

procedure TForm1.Backup();
var
  i,j,position:integer;
  todos_arquivos:TStringList;
  arquivo_origem,arquivo_destino:String;
begin
 ListBoxArquivosCopiado.Items.clear;
 ListBoxArquivosErros.Items.clear;
 ListBoxArquivosASeremCopiados.Clear;
 //FindAllFiles(MemoDiretorios.Lines, PastaOrigem, '*.*', true); //find e.g. all pascal sourcefiles
 //FindAllFiles(MemoDiretorios.Lines, PastaOrigem, '*.*', false); //find e.g. all pascal sourcefiles
 arquivo_origem:='';
 arquivo_destino:='';
 for j:=0 to usuarios.Count-1 do
 for i:=1 to Length(pastas) do
 begin
   todos_arquivos:=TStringList.create;
   try
      FindAllFiles(todos_arquivos,PastaOrigem+'\'+usuarios[j]+'\'+pastas[I],'*.*', true);
      ListBoxArquivosASeremCopiados.items.AddStrings(todos_arquivos);
   finally
   end;
 end;
 ListBoxArquivosASeremCopiados.refresh;
 for i:=0 to ListBoxArquivosASeremCopiados.Items.Count-1 do
 begin
   arquivo_origem:=ListBoxArquivosASeremCopiados.Items[i];
   arquivo_destino:=StringReplace(arquivo_origem,PastaOrigem,PastaDestino+'\'+PastaBackup,[rfReplaceAll, rfIgnoreCase]);
   CreateDir(PastaDestino+'\'+PastaBackup);
     ForceDirectories(ExtractFilePath(arquivo_destino));
     if (CopyFile(arquivo_origem,arquivo_destino)) then
     begin
       ListBoxArquivosCopiado.Items.Add(arquivo_destino)
     end
     else
     begin
       ListBoxArquivosErros.Items.Add(arquivo_origem);
     end;
     //IF (I MOD 10 =1) THEN
     begin
       ListBoxArquivosCopiado.Refresh;
       position:=round(((i+1)/ListBoxArquivosASeremCopiados.Items.Count)*100);
       MyThread.Progresso(position);
       ProgressBarProgresso.refresh;
       Form1.Refresh;
       //sleep(100);
     end;
 end;

end;

function TForm1.valida_usuarios_tecnicos(usuario: string): boolean;
var
  i:integer;
  resultado:Boolean;
begin
  resultado:=false;
  for i:=1 to Length(usuarios_tecnicos) do
     if(usuarios_tecnicos[i]=usuario)  then
     begin
       resultado:=true;
       break;
     end;
  result:=resultado;
end;

function TForm1.valida_usuarios_padrao(usuario: string): boolean;
var
  i:integer;
  resultado:Boolean;
begin
  resultado:=false;
  for i:=1 to Length(usuarios_padrao) do
     if(usuarios_padrao[i]=usuario)  then
     begin
       resultado:=true;
       break;
     end;
  result:=resultado;
end;

end.

