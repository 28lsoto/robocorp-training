*** Settings ***
Documentation    Orders robots from RobotSpareBin Industries INC
...    Saves the order HTML receipt as a PDF file.
...    Saves the screenshot of the orderer robot.
...    Embeds the screenshot of the robot to the PDF receipt.
...    Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Robocloud.Secrets
Library    RPA.Dialogs

*** Variables ***
${receiptoutputs}=    ${OUTPUT_DIR}${/}receipts${/}

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Add text input    zipname    Output File Name
    ${response}=    Run dialog
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${element}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${element}[Head]    ${element}[Body]    ${element}[Legs]    ${element}[Address]
        Preview the robot
        Wait Until Keyword Succeeds    15x    0.1s    Submit the order
        Store the receipt as a PDF file    ${element}[Order number]
        Go to Another Order
    END
    
    Log To Console    ${response}
    Archive Folder With Zip    ${receiptoutputs}    ${OUTPUT_DIR}${/}${response}[zipname].zip

*** Keywords ***
Fill the form 
    [Arguments]    ${head}    ${body}     ${legs}    ${address}
    Select From List By Value    name:head    ${head}    
    Select Radio Button    body    ${body}
    Input Text    name:address    ${address}
    Input Text    xpath=//input[@type="number"]    ${legs}

Store the receipt as a PDF file
    [Arguments]    ${orderNumber} 
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${receiptoutputs}robot_${orderNumber}.pdf
    Screenshot    id:robot-preview-image    ${receiptoutputs}robot_screenshot_${orderNumber}.png
    ${image}=    Create List    ${receiptoutputs}robot_screenshot_${orderNumber}.png
    Add Files To Pdf    ${image}    ${receiptoutputs}robot_${orderNumber}.pdf    page=2

Go to Another Order
    Click Button    id:order-another
Submit the order
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt
Preview the robot
    Click Button    id:preview
Close the annoying modal
    Click Button    xpath=//button[@class="btn btn-dark"]

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    ${OUTPUT_DIR}
    ${table}=    Read table from CSV    ${OUTPUT_DIR}/orders.csv
    [Return]    ${table}

Open the robot order website
    ${urls}    Get Secret    sites
    Open Browser    ${urls}[orders]
    Maximize Browser Window



