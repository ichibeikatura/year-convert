;;; year-convert.el --- 西暦・和暦変換 -*- lexical-binding: t -*-

(defvar year-convert-gengo-table
  '((reiwa  "令和" 2019)
    (heisei "平成" 1989)
    (showa  "昭和" 1926)
    (taisho "大正" 1912)
    (meiji  "明治" 1868))
  "元号テーブル")

(defvar year-convert-kanji-digits
  ["〇" "一" "二" "三" "四" "五" "六" "七" "八" "九"])

(defun year-convert--to-kanji (n)
  "数字Nを位取り漢数字に変換 (11→一一)"
  (if (= n 1) "元"
    (mapconcat (lambda (c) (aref year-convert-kanji-digits (- c ?0)))
               (number-to-string n) "")))

(defun year-convert--from-kanji-kurai (str)
  "位取り漢数字を数値に変換 (一一→11)"
  (if (string= str "元") 1
    (let ((res 0))
      (dolist (c (string-to-list str) res)
        (setq res (+ (* res 10)
                     (or (cl-position (char-to-string c) year-convert-kanji-digits :test #'string=) 0)))))))

(defun year-convert--seireki-to-wareki (year)
  (cl-loop for (sym name start) in year-convert-gengo-table
           when (>= year start) return (cons name (1+ (- year start)))))

(defun year-convert--wareki-to-seireki (name year)
  (cl-loop for (sym n s) in year-convert-gengo-table
           when (string= n name) return (+ s year -1)))

(defun year-convert-at-point ()
  (interactive)
  (let* ((case-fold-search nil)
         (gengo-re "\\(明治\\|大正\\|昭和\\|平成\\|令和\\)")
         (kanji-re "[〇一二三四五六七八九元]+") ;; 漢数字のみ
         (limit (line-beginning-position)))
    (cond
     ;; 1. 引用形式: 明治三三(一九〇〇)年 → 明治三三年 (カッコを外す)
     ((looking-back (concat gengo-re "\\(" kanji-re "\\)(\\([〇一二三四五六七八九]+\\))年") limit t)
      (let* ((gengo (match-string 1))
             (wareki-kanji (match-string 2)))
        (replace-match (format "%s%s年" gengo wareki-kanji))))

     ;; 2. 位取り漢数字: 明治三三年 → 明治33年 (漢数字を数字に)
     ((looking-back (concat gengo-re "\\(" kanji-re "\\)年") limit t)
      (let* ((gengo (match-string 1))
             (num (year-convert--from-kanji-kurai (match-string 2))))
        (replace-match (format "%s%d年" gengo num))))

     ;; 3. 和暦(数字): 明治33年 → 1900 (西暦計算)
     ((looking-back (concat gengo-re "\\([0-9]+\\)年") limit t)
      (let* ((gengo (match-string 1))
             (num (string-to-number (match-string 2)))
             (seireki (year-convert--wareki-to-seireki gengo num)))
        (replace-match (number-to-string seireki))))

     ;; 4. 西暦: 1900 → 明治三三(一九〇〇)年 (引用形式を作成)
     ((looking-back "\\([12][0-9]\\{3\\}\\)" limit t)
      (let* ((seireki (string-to-number (match-string 1)))
             (wareki (year-convert--seireki-to-wareki seireki)))
        (when wareki
          (replace-match (format "%s%s(%s)年"
                                 (car wareki)
                                 (year-convert--to-kanji (cdr wareki))
                                 (year-convert--to-kanji seireki))))))

     (t (message "変換できる年が見つかりません")))))

(provide 'year-convert)
