;; my emacs config for the terminal

(menu-bar-mode 0)
(global-visual-line-mode 1)
(setq scroll-conservatively 100)
(setq inhibit-startup-message 0)

(delete-selection-mode 1)

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; functions
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

(defun xah-select-line ()
  "Select current line. If region is active, extend selection downward by line.
URL `http://xahlee.info/emacs/emacs/modernization_mark-word.html'
Version 2017-11-01"
  (interactive)
  (if (region-active-p)
      (progn
        (forward-line 1)
        (end-of-line))
    (progn
      (end-of-line)
      (set-mark (line-beginning-position)))))

(defun xah-extend-selection ()
  "Select the current word, bracket/quote expression, or expand selection.
Subsequent calls expands the selection.
when there is no selection,
• if cursor is on a any type of bracket (including parenthesis, quotation mark), select whole bracketed thing including bracket
• else, select current word.
when there is a selection, the selection extension behavior is still experimental. But when cursor is on a any type of bracket (parenthesis, quote), it extends selection to outer bracket.
URL `http://xahlee.info/emacs/emacs/modernization_mark-word.html'
Version: 2020-02-04 2022-05-16"
  (interactive)
  (if (region-active-p)
      (progn
        (let (($rb (region-beginning)) ($re (region-end)))
          (goto-char $rb)
          (cond
           ((looking-at "\\s(")
            (if (eq (nth 0 (syntax-ppss)) 0)
                (progn
                  ;; (message "left bracket, depth 0.")
                  (end-of-line) ; select current line
                  (set-mark (line-beginning-position)))
              (progn
                ;; (message "left bracket, depth not 0")
                (up-list -1 t t)
                (mark-sexp))))
           ((eq $rb (line-beginning-position))
            (progn
              (goto-char $rb)
              (let (($firstLineEndPos (line-end-position)))
                (cond
                 ((eq $re $firstLineEndPos)
                  (progn
                    ;; (message "exactly 1 line. extend to next whole line." )
                    (forward-line 1)
                    (end-of-line)))
                 ((< $re $firstLineEndPos)
                  (progn
                    ;; (message "less than 1 line. complete the line." )
                    (end-of-line)))
                 ((> $re $firstLineEndPos)
                  (progn
                    ;; (message "beginning of line, but end is greater than 1st end of line" )
                    (goto-char $re)
                    (if (eq (point) (line-end-position))
                        (progn
                          ;; (message "exactly multiple lines" )
                          (forward-line 1)
                          (end-of-line))
                      (progn
                        ;; (message "multiple lines but end is not eol. make it so" )
                        (goto-char $re)
                        (end-of-line)))))
                 (t (error "%s: logic error 42946" real-this-command ))))))
           ((and (> (point) (line-beginning-position)) (<= (point) (line-end-position)))
            (progn
              ;; (message "less than 1 line" )
              (end-of-line) ; select current line
              (set-mark (line-beginning-position))))
           (t
            ;; (message "last resort" )
            nil))))
    (progn
      (cond
       ((looking-at "\\s(")
        ;; (message "left bracket")
        (mark-sexp)) ; left bracket
       ((looking-at "\\s)")
        ;; (message "right bracket")
        (backward-up-list) (mark-sexp))
       ((looking-at "\\s\"")
        ;; (message "string quote")
        (mark-sexp)) ; string quote
       ;; ((and (eq (point) (line-beginning-position)) (not (looking-at "\n")))
       ;;  (message "beginning of line and not empty")
       ;;  (end-of-line)
       ;;  (set-mark (line-beginning-position)))
       ((or (looking-back "\\s_" 1) (looking-back "\\sw" 1))
        ;; (message "left is word or symbol")
        (skip-syntax-backward "_w" )
        ;; (re-search-backward "^\\(\\sw\\|\\s_\\)" nil t)
        (push-mark)
        (skip-syntax-forward "_w")
        (setq mark-active t)
        ;; (exchange-point-and-mark)
        )
       ((and (looking-at "\\s ") (looking-back "\\s " 1))
        ;; (message "left and right both space" )
        (skip-chars-backward "\\s " ) (set-mark (point))
        (skip-chars-forward "\\s "))
       ((and (looking-at "\n") (looking-back "\n" 1))
        ;; (message "left and right both newline")
        (skip-chars-forward "\n")
        (set-mark (point))
        (re-search-forward "\n[ \t]*\n")) ; between blank lines, select next block
       (t
        ;; (message "just mark sexp" )
        (mark-sexp)
        (exchange-point-and-mark))
       ;;
       ))))

(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)
(global-set-key (kbd "C-x v") 'xah-select-line)
(global-set-key (kbd "<f5>") 'compile)
(global-set-key (kbd "C-q") 'xah-extend-selection)
(global-set-key (kbd "C-x l") 'display-line-numbers-mode)
(global-set-key (kbd "C-S-<tab>") 'previous-buffer)
(global-set-key (kbd "C-<tab>") 'next-buffer)
(global-set-key (kbd "C-<iso-lefttab>") 'previous-buffer)
