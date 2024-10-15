#!/data/data/com.termux/files/usr/bin/bash
(
gerar_pays () {
  echo 'GET / HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: aprende.org[crlf][crlf]POST / HTTP/1.1[crlf]Host: cc2052.freenetrd.tk[crlf]Upgrade: freenetrd[crlf][crlf] ' > $HOME/$1
}

injector_fun(){
  #$0 lista ip porta
  if [[ -e /data/data/com.termux/files/usr/bin/python3 ]]; then
    PY="/data/data/com.termux/files/usr/bin/python3"
  elif [[ -e /data/data/com.termux/files/usr/bin/python3 ]]; then
    PY="/data/data/com.termux/files/usr/bin/python3"
  else
    pkg install python > /dev/null 2>&1
    return 1
  fi

  $PY -x << PYTHON
import socket, os, sys

class injector:
  def __init__(self, payload, conn):
    self.payload = payload
    self.conn = conn

  def iniciar(self):  
    print(repr("Payload: "+self.payload))
    self.conn.send(self.payload.encode())
    status = self.conn.recv(1024).split('\n'.encode())[0]
    aux = status
    print('Status: '+str(status))
    self.conn.close()

class gerarPay:
  def __init__(self, payload, use_proxy):
    self.payload = payload
    self.use_proxy = use_proxy

  def pay(self):
    aux = self.payload.replace('[crlf]','\r\n')
    aux = aux.replace('[lf]','\n')
    aux = aux.replace('[cr]','\r')
    aux = aux.replace('[method]','CONNECT')
    aux = aux.replace('[host_port]','$2:22')  # Puerto que usa el payload
    aux = aux.replace('[host]','$2')
    aux = aux.replace('[port]','22')
    aux = aux.replace('[netData]','CONNECT $2:22 HTTP/1.0')
    aux = aux.replace('[realData]','CONNECT $2:22 HTTP/1.0')
    aux = aux.replace('[raw]','CONNECT $2:22 HTTP/1.0')
    aux = aux.replace('[protocol]','HTTP/1.0')

    if self.use_proxy:
      aux = aux.replace('$2', '$proxy_ip')  # Reemplazar el host con el proxy IP si se usa proxy

    return aux

class ListPay:
  def __init__(self, arg, use_proxy):
    self.list = arg
    self.use_proxy = use_proxy

  def EnviarPay(self):
    _pay = self.list

    # Si se usa proxy, se conecta a la IP del proxy
    if self.use_proxy:
      conn_target = ('$proxy_ip', int('$port'))
    else:
      conn_target = ('$2', int('$3'))  # $2 será el host, $3 el puerto

    # Crear conexión a la dirección y puerto adecuados
    self.conn = socket.create_connection(conn_target, timeout=2)
    _PAY_ = gerarPay(_pay, self.use_proxy).pay()
    a = injector(_PAY_, self.conn)
    a.iniciar()

def main():
  sta = ListPay("$1", True if "$use_proxy" == "1" else False)
  sta.EnviarPay()

if __name__ == '__main__':
  main()
PYTHON
}

echo -ne "Bienvenido a " 
echo -ne "Payload Tester by Colla " 
echo -ne "Digite el Host: " && read valor1 # Entrada Host
echo -ne "¿Desea usar un proxy? (s/n): " && read proxy_choice
if [[ "$proxy_choice" == "s" ]]; then
  echo -ne "Digite un PROXY:PORT: " && read svar # Entrada proxy
  proxy_ip="$(echo $svar | cut -d':' -f1)"  # IP del proxy
  port="$(echo $svar | cut -d':' -f2)"  # Puerto del proxy
  use_proxy=1  # Sí, usar proxy
else
  use_proxy=0  # No, no usar proxy
  valor2="$valor1"  # Si no se usa proxy, el valor del host se asigna directamente a valor2
  port=80  # Usa puerto 80 por defecto si no hay proxy
fi

retorno="GET CONNECT PUT OPTIONS DELETE HEAD PATCH POST"
i=1
for ech in $retorno; do
  ech_ret="[$i]$ech" && let i++
  while [[ ${#ech_ret} -lt "15" ]]; do ech_ret=$ech_ret' '; done
  NUM=$[ $i & 1 ]
  if [[ $NUM = 0 ]]; then
    reto+="$ech_ret"
  else
    echo -e "$reto $ech_ret"
    unset reto
  fi
done

echo -ne "Escoja un metodo de request: " && read valor3 # Método Requisición
echo -e "[1]realData\n[2]netData\n[3]raw"
echo -ne "Escoja un metodo de conexion: " && read valor4 # Método Conexión

case $valor3 in
  1) req="GET";;
  2) req="CONNECT";;
  3) req="PUT";;
  4) req="OPTIONS";;
  5) req="DELETE";;
  6) req="HEAD";;
  7) req="PATCH";;
  8) req="POST";;
  *) req="GET";;
esac

case $valor4 in
  1) in="realData";;
  2) in="netData";;
  3) in="raw";;
  *) in="netData";;
esac

gerar_pays Payloads.txt
sed -i "s;realData;abc;g" $HOME/Payloads.txt
sed -i "s;netData;abc;g" $HOME/Payloads.txt
sed -i "s;raw;abc;g" $HOME/Payloads.txt
sed -i "s;abc;$in;g" $HOME/Payloads.txt
sed -i "s;GET;$req;g" $HOME/Payloads.txt
sed -i "s;get;$req;g" $HOME/Payloads.txt
sed -i "s;mhost;$valor1;g" $HOME/Payloads.txt
sed -i "s;mip;$valor2;g" $HOME/Payloads.txt

echo -e "Payloads Generados... Probando..."
barra="\033[1;36m====================================================================================="
barra2="\033[1;36m**************************************************************************************************"
echo -e "$barra"
echo -e "$barra2"

while read payload; do
  echo -e "\033[1;31mPAYLOAD PARA INJECTOR:\n $payload\n"
  retorn=$(injector_fun "$payload" $valor2 $port $use_proxy)
  echo -e "\033[1;33m $(echo -e $retorn|grep -v Status)"
  echo -e "\033[1;32m$(echo -e $retorn|grep established)"
  echo -e "\033[1;31m$(echo -e $retorn|grep Status)"
  echo -e "$barra"
  echo -e "$barra2"
done < $HOME/Payloads.txt

echo -e "COMPLETADO!\033[0m"
) |& tee colla.log