*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.Windows
Library             RPA.Excel.Application
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.JavaAccessBridge
Library             RPA.PDF
Library             RPA.Robocorp.Process
Library             comprimir.py
Library             RPA.Archive
Library             Dialogs
Library             RPA.Robocorp.Vault
Library             RPA.FileSystem


*** Variables ***
${N}


*** Tasks ***
Abrimos pagina web
    ${Extension}=    Set Variable    .zip
    ${ZIP}=    Get Value From User    Input Nombre Fichero ZIP
    ${Extension}=    Set Variable    ${ZIP}${Extension}
    Log    ${ZIP}
    Abrir web
    Abrir CSV
    Comprimir    ${ZIP}    ${OUTPUT_DIR}${/}CERTIFICACION
    Log    ${OUTPUT_DIR}${/}CERTIFICACION
    #Archive Folder With Zip    ${OUTPUT_DIR}${/}CERTIFICACION    ${ZIP}
    Copy File    ${Extension}    ${OUTPUT_DIR}${/}${Extension}
    Sleep    150s
    #${position}=    Get Mouse Position
    #Log    Current mouse position is ${position.x}, ${position.y}


*** Keywords ***
Abrir web
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order    maximized=true
    Sleep    2s
    Click Element If Visible    //button[@type='button'][contains(.,'OK')]

Abrir CSV
    ${secret}=    Get Secret    credentials2
    Log    ${secret}
    Download    ${secret}[web]
    #Download    https://robotsparebinindustries.com/orders.csv
    #Open Workbook    ./orders.csv
    ${CSV}=    Read table from CSV    ./orders.csv
    ${N}=    Set Variable    0
    FOR    ${fila}    IN    @{CSV}
        Log    ${fila}
        Click Element If Visible    //button[@type='button'][contains(.,'OK')]
        Select From List By Index    //select[contains(@id,'head')]    ${fila}[Head]
        Rpa.Browser.Selenium.Click Element    //label[@for='id-body-${fila}[Body]']
        Input Text    //input[contains(@type,'number')]    ${fila}[Legs]
        Input Text    //input[contains(@id,'address')]    ${fila}[Address]
        Click Button    //button[@type='submit'][contains(.,'Preview')]
        Click Button    //button[@type='submit'][contains(.,'Order')]
        FOR    ${counter}    IN RANGE    1    5    1
            Log    ${counter}
            TRY
                ${Texto}=    Get Element Attribute    id:receipt    outerHTML
                Log    Try
                BREAK
            EXCEPT
                Click Button    //button[@type='submit'][contains(.,'Order')]
                Log    Catch
            END
        END

        ${N}=    Set Variable    ${${N}+1}
        Pasar a PDF    ${Texto}    ${N}
        Log    ${Texto}
        Click Button    id:order-another
    END

Prueba FlexApp
    Control Window    FlexApp
    Click    class:QQuickLoader_QML_150 offset:10,0
    Click Coordinates    402    92

Pasar a PDF
    [Arguments]    ${Texto}    ${N}
    Html To Pdf    ${Texto}    ${OUTPUT_DIR}${/}sales_results.pdf
    Rpa.Browser.Selenium.Screenshot    id:robot-preview-image    filename=${OUTPUT_DIR}${/}imagen.png
    Add Watermark Image To Pdf
    ...    image_path=${OUTPUT_DIR}${/}imagen.png
    ...    source_path=${OUTPUT_DIR}${/}sales_results.pdf
    ...    output_path=${OUTPUT_DIR}${/}CERTIFICACION/pedido_${N}.pdf
