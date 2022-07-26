import { LightningElement,wire ,track} from 'lwc';
import getAllFilteredAssets from '@salesforce/apex/FilteredAssetsController.getAllFilteredAssets';

export default class GetSpecificAsset extends LightningElement {
//Includes three columns - Name, Account Name and Contract Number from Asset
columns=[
{label:'Asset Name',fieldName:'Name',type:'text'},
{label:'Account Name',fieldName:'Account_Name__c',type:'text'},
{label:'Contract Number',fieldName:'Contract_Number__c',type:'Number'}
];

assets=[];
rowOffset = 0;
columnHeader = ['ID', 'Asset Name', 'Account Name', 'Contract Number' ];
@wire (getAllFilteredAssets) assetData({error,data}){
    //If data successfully fetched then store it in assets
    if(data){
        this.assets = data;
        
        console.log('** This is our fetched data **',JSON.stringify(this.assets));
       
    }     
    //If error occurs then set assets to undefined 
    else if(error){
        this.assets=undefined;
        console.log('Failing to fetch data');
       
        console.log('** Failed to fetch the data **',JSON.stringify(error));
       
    }
}

 // this method validates the data and creates the csv file to download
 downloadCSVFile() {   
    let rowEnd = '\n';
    let csvString = '';
    // this set elminates the duplicates if have any duplicate keys
    let rowData = new Set();

    // getting keys from data
    this.assets.forEach(function (record) {
        Object.keys(record).forEach(function (key) {
            rowData.add(key);
        });
    });
    console.log(rowData);
    // Array.from() method returns an Array object from any object with a length property or an iterable object.
    rowData = Array.from(rowData);
    
    // splitting using ','
    csvString += rowData.join(',');
    csvString += rowEnd;

    // main for loop to get the data based on key value
    for(let i=0; i < this.assets.length; i++){
        let colValue = 0;

        // validating keys in data
        for(let key in rowData) {
            if(rowData.hasOwnProperty(key)) {
                // Key value 
                // Ex: Id, Name
                let rowKey = rowData[key];
                // add , after every value except the first.
                if(colValue > 0){
                    csvString += ',';
                }
                // If the column is undefined, it as blank in the CSV file.
                let value = this.assets[i][rowKey] === undefined ? '' : this.assets[i][rowKey];
                csvString += '"'+ value +'"';
                colValue++;
            }
        }
        csvString += rowEnd;
    }

    // Creating anchor element to download
    let downloadElement = document.createElement('a');

    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    downloadElement.target = '_self';
    // CSV File Name
    downloadElement.download = 'Asset Data.csv';
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click(); 
}

// exportfilteredAssetData(){
//     // Prepare a html table
//     let doc = '<table>';
//     // Add styles for the table
//     doc += '<style>';
//     doc += 'table, th, td {';
//     doc += '    border: 0.5px solid black;';
//     doc += '    border-collapse: collapse;';
//     doc += '}';          
//     doc += '</style>';
//     // Add all the Table Headers
//     doc += '<tr>';
//     this.columnHeader.forEach(element => {            
//         doc += '<th>'+ element +'</th>'           
//     });
//     doc += '</tr>';
//     // Add the data rows
//     this.assets.forEach(record => {
//         doc += '<tr>';
//         doc += '<td>'+record.Id+'</td>'; 
//         doc += '<td>'+record.Name+'</td>'; 
//         doc += '<td>'+record.Account_Name__c+'</td>';
//         doc += '<td>'+record.Contract_Number__c+'</td>'; 
//         doc += '</tr>';
//     });
//     doc += '</table>';
//    // var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
//     var element = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' + encodeURIComponent(doc);
//     let downloadElement = document.createElement('a');
//     downloadElement.href = element;
//     downloadElement.target = '_self';
//     // use .csv as extension on below line if you want to export data as csv
//     downloadElement.download = 'Asset Data.xlsx';
//     document.body.appendChild(downloadElement);
//     downloadElement.click();
// }
}