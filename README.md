# year-convert

カーソル位置にある年表記を、西暦と和暦の間でトグル変換（循環）させるEmacsパッケージです。西暦・和暦（数字/漢数字/引用形式）をカーソル位置でトグル変換するEmacs拡張。 (An Emacs package that cycles through Western year and Japanese Era formats at point.)

## 特徴

カーソル上の年を以下の順序で変換します。

1. **西暦** (例: `1900`)
2. **引用形式** (例: `明治三三(一九〇〇)年`) ※歴史記述に便利
3. **和暦・漢数字** (例: `明治三三年`)
4. **和暦・数字** (例: `明治33年`)
5. (最初に戻る)

## 使い方

変換したい年の上にカーソルを置き、設定したコマンド（例: `M-x year-convert-at-point`）を実行するだけです。

## 設定例

GitHub からインストールし、`C-M-=` に変換キーを割り当てる設定例です。

### use-package (Elpaca) の場合
```lisp
(use-package year-convert
  :ensure (year-convert :url "https://github.com/ichibeikatura/year-convert")
  :bind ("C-M-=" . year-convert-at-point))
```

### leaf の場合
```lisp
(leaf year-convert
  :elpaca (year-convert :url "https://github.com/ichibeikatura/year-convert")
  :bind ("C-M-=" . year-convert-at-point))
```
