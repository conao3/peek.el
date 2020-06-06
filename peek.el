;;; peek.el --- Show peek window for grep  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>
;; Version: 0.0.1
;; Keywords: convenience
;; Package-Requires: ((emacs "26.1"))
;; URL: https://github.com/conao3/peek.el

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Show peek window for grep.


;;; Code:

(defgroup peek nil
  "Show peek window for grep."
  :group 'convenience
  :link '(url-link :tag "Github" "https://github.com/conao3/peek.el"))


;;; Functions

(defvar compilation-current-error)
(defvar compilation-context-lines)
(defvar-local peek-window nil "The window used by peek.")
(defvar-local peek-last-error-line nil "Last visit error line.")


;;; Main

(declare-function 'compile-goto-error "compile")

(defun peek-error ()
  "Peek current line."
  (pop-to-buffer (peek--error-noselect)))

(defun peek-error-noselect ()
  "Peek current line with noselect."
  (interactive)
  (let ((buf (cond
              ((derived-mode-p major-mode '(compilation-mode))
               (save-window-excursion
                 (compile-goto-error)
                 (current-buffer)))
              (t
               (error "Major-mode: %s is not supported" major-mode)))))
    (cond
     ((and peek-window
           (window-live-p peek-window)
           (not (equal (selected-window) peek-window)))
      (set-window-buffer peek-window buf))
     (t
      (setq-local peek-window (display-buffer buf))))))

(defun peek-mode--hook-function ()
  "Hook function for `post-command-hook' in `peek-mode'.
see `next-error-follow-mode-post-command-hook'."
  (unless (equal peek-last-error-line (line-number-at-pos))
    (setq peek-last-error-line (line-number-at-pos))
    (ignore-errors
      (peek-error-noselect))))

(defun peek-mode--setup ()
  "Setup peek-mode."
  (setq-local peek-window (let ((w (next-window)))
                            (unless (equal w (selected-window)) w)))
  (add-hook 'post-command-hook 'peek-mode--hook-function))

(defun peek-mode--teardown ()
  "Setup peek-mode."
  (remove-hook 'post-command-hook 'peek-mode--hook-function t))

;;;###autoload
(define-minor-mode peek-mode
  "Enable peek-mode.
Minor change from `next-error-follow-minor-mode'."
  :lighter " peek"
  :group 'peek
  (if peek-mode
      (peek-mode--setup)
    (peek-mode--teardown)))

(provide 'peek)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; peek.el ends here
