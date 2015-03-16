Server Compaire Tool
----------------------

## 使い方

1. 共通設定ファイル作成
2. サーバAでダイジェストの作成
3. サーバBでダイジェストの作成
4. 差分比較

### 1. 共通設定ファイルの作成

以下のような設定ファイルを書きます。
設定ファイルには、比較対象にしたいファイルまたはディレクトリを書きます。

scomp.conf

    /etc
    /usr/local
    /opt/myapp/myapp.conf

### 2. サーバAでダイジェスト作成

共通設定ファイルをサーバAに置き、以下のようにダイジェストを作成します。

    # ./scomp_digest.sh -c scomp.conf
    make digest archive file : /root/scomp-serverA-20121210_022903.tar.gz
    
### 3. サーバBでダイジェスト作成

共通設定ファイルをサーバBに置き、以下のようにダイジェストを作成します。

    # ./scomp_digest.sh -c scomp.conf
    make digest archive file : /root/scomp-serverB-20121210_023900.tar.gz
    
### 4. 差分比較

上記で作った二つのダイジェスト使って差分比較します。

    # ./scomp_diff.sh scomp-serverA-20121210_022903.tar.gz scomp-serverB-20121210_023900.tar.gz

すると以下のように出ます。
```    
--------------------------
has difference     : /etc/group

[arg1]  /etc/group 93990436394a577b48de93c0c2cf7062 -rw-r--r-- root root
[arg2]  /etc/group 2d4848f9a455de1856d544a0aff2d94b -rw-r--r--. root root
[diff]
36d35
< ntp:x:38:
37a37
> ntp:x:38:
44,54d43
< rtkit:x:498:
< pulse:x:497:
```

## 動作

### ダイジェスト生成

* 設定ファイルに書いてあるpathに対して、path以下にあるファイルを比較対象とします
** ディレクトリ、シンボリックリンク、およびスペシャルデバイスファイルは対象外です。
* テキストファイルはそのファイルをダイジェストに入れますが、バイナリファイルは対象外です。

### 比較
* ファイルの比較はファイルのオーナ、パーミッション、およびmd5sumの値にて比較します。
** 更新日付、シンボリックリンク数はチェックしません
* テキストファイルの場合、diffの結果を表示しますが、バイナリファイルは表示しません。
