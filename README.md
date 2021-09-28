# backup
#backup only user data for windows system#

Este sistema foi desenvolvido na lingagem pascal utilizando a ide lazarus. 

Quando um computador ou notebook vai para assistência técnica na maioria das vezes precisa ser reinstalado o sistema operacional nele devido a falhas. Neste processo é realizado o um procedimento chamado backup que consiste em copiar os dados de cada usuário deste equipamento.

O estudo de caso segue o nome de cada usuário como padrão de nome e sobrenome desta forma nome.sobrenome com raras exceções esta presente um usuário local na maquina.

Entre os usuários presentes também há usuários padrões de sistema do Microsoft Windows 7 ou superior, além usuários padrões de sistema existem usuários técnicos que precisam entrar no computador. Ambos os usuários padrões e os técnicos não são importantes para o backup.

Para Eliminar os usuários técnicos for criada uma constante no sistema como a lista de todos os membros técnicos a fim de subtrair da lista de usuários de backup.

const usuarios_tecnicos:array [1..4] of String=( 'tecnico1.informatica', 'tecnico2.informatica', 'tecnico3.informatica', 'tecnico4.informatica' ); 

Outra constante é definida é as pastas padrões de sistema a serem copidadas

const pastas:array [1..8] of String=( 'Desktop', 'Documents', 'Downloads', 'Favorites', 'Music', 'OneDrive', 'Pictures', 'Videos' );

Por padrão a pasta backup é enviada em um hd esterno como o nome composto por o nome do local que foi relizado o equipamento exemplo "Contabilidade" junto com "PC" seguido do número de patrimôneo do dispositivo e a data atual.

 pastaBackup:='Backup '+EditLocal.Text+' PC'+MaskEditPatrimoneo.text+' '+StringReplace(DATETOSTR(CalendarData.DateTime),'/','-',[rfReplaceAll, rfIgnoreCase]);
