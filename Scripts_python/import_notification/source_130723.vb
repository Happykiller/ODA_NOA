Public Sub script(ByVal Mail As MailItem)
    On Error GoTo ErrMsg
        MYSTRING = Format(Now(), "yyyymmdd_hhnnss")
    
        file = "notification_" + MYSTRING + ".txt"
        
        path_file = "C:\mail\notification_" + MYSTRING + ".txt"
        
        Body = MailBody(Mail)
        
        Call CreateFile(path_file, Body)
        
        Shell "cmd /c python D:\FRO\APP\ODA_NOA\www\Scripts_python\import_notification\script_import_notification.py D:\FRO\APP\ODA_NOA\www\Scripts_python\import_notification\exemple.config.api.oda_noa.json importer " + file
    Exit Sub
ErrMsg:
        If Err.Number <> 0 Then
            msg = "Error # " & Str(Err.Number) & " was generated by " _
            & Err.Source & Chr(13) & Err.Description
            MsgBox msg, , "Error", Err.HelpFile, Err.HelpContext
        End If
End Sub

Public Function MailBody(ByVal MailItem As MailItem) As String
    Select Case MailItem.BodyFormat
        Case OlBodyFormat.olFormatPlain, OlBodyFormat.olFormatUnspecified
            MailBody = MailItem.Body
        Case OlBodyFormat.olFormatHTML
            MailBody = MailItem.HTMLBody
        Case OlBodyFormat.olFormatRichText
            MailBody = MailItem.RTFBody
    End Select
End Function

Public Sub CreateFile(ByVal pstrFile As String, ByVal pstrData As String)
    Dim objStream As Object
    'Create the stream
    Set objStream = CreateObject("ADODB.Stream")
 
    'Initialize the stream
    objStream.Open
 
    'Reset the position and indicate the charactor encoding
    objStream.Position = 0
    objStream.Charset = "UTF-8"
 
    'Write to the steam
    objStream.WriteText pstrData
 
    'Save the stream to a file
    objStream.SaveToFile pstrFile
End Sub

