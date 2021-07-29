@description('Which Azure region')
param region string

var regionShortCode = {
  ChinaEast :{
    shortCode: 'cne'
  }
  ChinaEast2 : {
    shortCode: 'cne2' 
  }
  ChinaNorth : {
    shortCode: 'cnn'
  }
  ChinaNorth2 : {
    shortCode: 'cnn2'
  }
  AustraliaCentral : {
    shortCode: 'auc'
  }
  AustraliaCentral2 : {
    shortCode: 'auc2'
  }
  AustraliaEast : {
    shortCode: 'aue'
  }
  AustraliaSoutheast : {
    shortCode: 'ause'
  }
  BrazilSouth : {
    shortCode: 'brs'
  }
  BrazilSoutheast : {
    shortCode: 'brse'
  }
  CanadaCentral : {
    shortCode: 'cac'
  }
  CanadaEast: {
    shortCode: 'cae'
  }
  CentralIndia : {
    shortCode: 'cin'
  }
  CentralUS : {
    shortCode: 'cus'
  }
  EastAsia : {
    shortCode: 'eas'
  }
  EastUS : {
    shortCode: 'eus'
  }
  EastUS2 : {
    shortCode: 'eus2'
  }
  FranceCentral : {
    shortCode: 'frc'
  }
  FranceSouth : {
    shortCode: 'frs'
  }
  GermanyNorth : {
    shortCode: 'gen'
  }
  GermanyWestCentral : {
    shortCode: 'gewc'
  }
  JapanEast : {
    shortCode: 'jpe'
  }
  JapanWest: {
    shortCode: 'jpw'
  }
  JioIndiaWest : {
    shortCode: 'jiw'
  }
  KoreaCentral : {
    shortCode: 'koc'
  }
  KoreaSouth: {
    shortCode: 'kos'
  }
  NorthCentralUS : {
    shortCode: 'ncus'
  }
  NorthEurope : {
    shortCode: 'neu'
  }
  NorwayEast: {
    shortCode: 'noe'
  }
  NorwayWest : {
    shortCode: 'now'
  }
  SouthAfricaNorth : {
    shortCode: 'zan'
  }
  SouthAfricaWest : {
    shortCode: 'zaw'
  }
  SouthCentralUS : {
    shortCode: 'scus'
  }
  SouthIndia : {
    shortCode: 'sin'
  }
  SoutheastAsia : {
    shortCode: 'sea'
  }
  SwitzerlandNorth : {
    shortCode: 'chn'
  }
  SwitzerlandWest : {
    shortCode: 'chw'
  }
  UAECentral: {
    shortCode: 'uaew'
  }
  UAENorth : {
    shortCode: 'uaee'
  }
  UKSouth : {
    shortCode: 'uks'
  }
  UKWest : {
    shortCode: 'ukw'
  }
  WestCentralUS : {
    shortCode: 'wcus'
  }
  WestEurope: {
    shortCode: 'weu'
  }
  WestIndia : {
    shortCode: 'win'
  }
  WestUS : {
    shortCode: 'wus'
  }
  WestUS2 : {
    shortCode: 'wus2'
  }
  WestUS3 : {
    shortCode: 'wus3'
  }
}

output regionShortName string = regionShortCode[region].shortCode
//output instanceCount int = environmentSettings[environmentName].instanceCount
