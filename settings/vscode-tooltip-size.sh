locate workbench.main.css

# at the end of css file:
/* suggest-widget size */
 .monaco-editor .suggest-widget.docs-side {
    width: 1600px !important;
}
.monaco-editor .suggest-widget.docs-side > .details {
    width: 70% !important;
    max-height: 800px !important;
}
.monaco-editor .suggest-widget.docs-side > .tree {
    width: 30% !important;
    float: left !important;
}

/* parameter-hints-widget */
.editor-widget.parameter-hints-widget.visible {
    max-height: 800px !important;
}
.monaco-editor .parameter-hints-widget > .wrapper {
    max-width: 1600px !important;
}

/* editor-hover */
.monaco-editor-hover .monaco-editor-hover-content {
    max-width: 1600px !important;
}

# restart vscode
