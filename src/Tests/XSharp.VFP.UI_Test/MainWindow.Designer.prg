﻿//------------------------------------------------------------------------------
//  <auto-generated>
//     This code was generated by a tool.
//     Runtime version: 4.0.30319.42000
//     Generator      : XSharp.CodeDomProvider 2.16.0.0
//     Timestamp      : 09/05/2023 18:07:27
//
//     Changes to this file may cause incorrect behavior and may be lost if
//     the code is regenerated.
//  </auto-generated>
//------------------------------------------------------------------------------
BEGIN NAMESPACE XSharp.VFP.UI_Test

    PUBLIC PARTIAL CLASS MainWindow

        /// <summary>
        /// Required designer variable.
        /// </summary>
        private components	:=	NULL AS System.ComponentModel.IContainer
		PRIVATE menuStrip1 AS System.Windows.Forms.MenuStrip
		PRIVATE testToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
		PRIVATE miscControlsToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
		PRIVATE textBoxToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
		PRIVATE toolStripSeparator1 AS System.Windows.Forms.ToolStripSeparator
		PRIVATE quitToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem
		PRIVATE dOFORMToolStripMenuItem AS System.Windows.Forms.ToolStripMenuItem

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override method Dispose(disposing as logic) as void strict

            if (disposing .and. (components != null))
                components:Dispose()
            endif
            Super:Dispose(disposing)
			return
        end method
        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private METHOD InitializeComponent() AS VOID STRICT
			SELF:menuStrip1	:=	System.Windows.Forms.MenuStrip{}
			SELF:testToolStripMenuItem	:=	System.Windows.Forms.ToolStripMenuItem{}
			SELF:miscControlsToolStripMenuItem	:=	System.Windows.Forms.ToolStripMenuItem{}
			SELF:textBoxToolStripMenuItem	:=	System.Windows.Forms.ToolStripMenuItem{}
			SELF:toolStripSeparator1	:=	System.Windows.Forms.ToolStripSeparator{}
			SELF:quitToolStripMenuItem	:=	System.Windows.Forms.ToolStripMenuItem{}
			SELF:dOFORMToolStripMenuItem	:=	System.Windows.Forms.ToolStripMenuItem{}
			SELF:menuStrip1:SuspendLayout()
			SELF:SuspendLayout()
			//
			//	menuStrip1
			//
			SELF:menuStrip1:ImageScalingSize	:=	System.Drawing.Size{20, 20}
			SELF:menuStrip1:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:testToolStripMenuItem })
			SELF:menuStrip1:Location	:=	System.Drawing.Point{0, 0}
			SELF:menuStrip1:Name	:=	"menuStrip1"
			SELF:menuStrip1:Size	:=	System.Drawing.Size{282, 28}
			SELF:menuStrip1:TabIndex	:=	0
			SELF:menuStrip1:Text	:=	"menuStrip1"
			//
			//	testToolStripMenuItem
			//
			SELF:testToolStripMenuItem:DropDownItems:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:miscControlsToolStripMenuItem, SELF:textBoxToolStripMenuItem, SELF:dOFORMToolStripMenuItem, SELF:toolStripSeparator1, SELF:quitToolStripMenuItem })
			SELF:testToolStripMenuItem:Name	:=	"testToolStripMenuItem"
			SELF:testToolStripMenuItem:Size	:=	System.Drawing.Size{49, 24}
			SELF:testToolStripMenuItem:Text	:=	"Test"
			//
			//	miscControlsToolStripMenuItem
			//
			SELF:miscControlsToolStripMenuItem:Name	:=	"miscControlsToolStripMenuItem"
			SELF:miscControlsToolStripMenuItem:Size	:=	System.Drawing.Size{224, 26}
			SELF:miscControlsToolStripMenuItem:Text	:=	"Misc Controls"
			SELF:miscControlsToolStripMenuItem:Click	+=	System.EventHandler{ SELF, @miscControlsToolStripMenuItem_Click() }
			//
			//	textBoxToolStripMenuItem
			//
			SELF:textBoxToolStripMenuItem:Name	:=	"textBoxToolStripMenuItem"
			SELF:textBoxToolStripMenuItem:Size	:=	System.Drawing.Size{224, 26}
			SELF:textBoxToolStripMenuItem:Text	:=	"TextBox"
			SELF:textBoxToolStripMenuItem:Click	+=	System.EventHandler{ SELF, @textBoxToolStripMenuItem_Click() }
			//
			//	toolStripSeparator1
			//
			SELF:toolStripSeparator1:Name	:=	"toolStripSeparator1"
			SELF:toolStripSeparator1:Size	:=	System.Drawing.Size{221, 6}
			//
			//	quitToolStripMenuItem
			//
			SELF:quitToolStripMenuItem:Name	:=	"quitToolStripMenuItem"
			SELF:quitToolStripMenuItem:Size	:=	System.Drawing.Size{224, 26}
			SELF:quitToolStripMenuItem:Text	:=	"Quit"
			SELF:quitToolStripMenuItem:Click	+=	System.EventHandler{ SELF, @quitToolStripMenuItem_Click() }
			//
			//	dOFORMToolStripMenuItem
			//
			SELF:dOFORMToolStripMenuItem:Name	:=	"dOFORMToolStripMenuItem"
			SELF:dOFORMToolStripMenuItem:Size	:=	System.Drawing.Size{224, 26}
			SELF:dOFORMToolStripMenuItem:Text	:=	"DO FORM"
			SELF:dOFORMToolStripMenuItem:Click	+=	System.EventHandler{ SELF, @dOFORMToolStripMenuItem_Click() }
			//
			//	MainWindow
			//
			SELF:Controls:Add(SELF:menuStrip1)
			SELF:MainMenuStrip	:=	SELF:menuStrip1
			SELF:Name	:=	"MainWindow"
			SELF:Text	:=	"MainWindow"
			SELF:menuStrip1:ResumeLayout(false)
			SELF:menuStrip1:PerformLayout()
			SELF:ResumeLayout(false)
			SELF:PerformLayout()
		END METHOD
        #endregion
    END CLASS
END NAMESPACE
