//
//  BasicReportsQuestion.swift
//  cafm
//
//  Created by NS on 01/12/24.
//  
//

import Foundation

typealias BasicReportsQuestion = (
    question: String,
    key: String,
    main: String
)

let basicReportsQuestions: [BasicReportsQuestion] = [
    (
        question:
            "Where the Building is / is not Under the Control of the Client",
        key: "buildingUnderClientControl",
        main: "siteInfoData"
    ),
    (
        question: "Where security Guards are / are not Employed",
        key: "securityGuardEmployed",
        main: "siteSafetyData"
    ),
    (
        question: "Where there is / is not a Canteen within the Building",
        key: "canteenInBuilding",
        main: "siteInfoData"
    ),
    (
        question:
            "Where there is / is not a Dedicated Kitchen Area within the Building",
        key: "dedicatedKitchenArea",
        main: "siteInfoData"
    ),
    (
        question: "Where there is / is not areas considered as Confined Spaces",
        key: "confinedSpaces",
        main: "siteSafetyData"
    ),
    (
        question:
            "Where there is / is not areas considered as an Accessible Unguarded Roof Area(s)",
        key: "accessibleUnguardedRoofAreas",
        main: "siteSafetyData"
    ),
    (
        question:
            "Where there is / is not surface(s) considered as Fragile Roofs or Surfaces",
        key: "fragileRoof",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not contain a permanent Gas Supply",
        key: "utilGas",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not contain a permanent Electricity Supply",
        key: "utilElectricity",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not contain a permanent Water Supply",
        key: "utilWater",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not contain a permanent Telecom/Data Supply",
        key: "utilTelecom",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not have Mains Drainage",
        key: "utilMainsDrainage",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not have a Lighting Conductor",
        key: "lightingConductoreInstalltion",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have Air Conditioning",
        key: "airConditioning",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not have a Cooling Tower",
        key: "coolingTower",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not have Water Storage Tanks",
        key: "waterTanks",
        main: "siteEnergyData"
    ),
    (
        question: "That do / do not contain a Gas Boiler",
        key: "gasBoiler",
        main: "siteEnergyData"
    ),
    (
        question: "That do /do not have an Electric Sub-Station on Site",
        key: "electricSubStationOnSite",
        main: "siteEnergyData"
    ),
    (
        question: "That do /do not have a Back Up Generator on Site",
        key: "backupGenerator",
        main: "siteEnergyData"
    ),
    (
        question: "That do /do not have a Fire Alarm/Detection System",
        key: "fireAlarmSystem",
        main: "siteSafetyData"
    ),
    (
        question: "That do /do not have a Sprinkler System",
        key: "sprinklerSystem",
        main: "siteSafetyData"
    ),
    (
        question: "That do /do not have Hose Reels",
        key: "hoseReels",
        main: "siteSafetyData"
    ),
    (
        question: "That do /do not have Internal CCTV",
        key: "internalCCTV",
        main: "siteSafetyData"
    ),
    (
        question: "That do /do not have External CCTV",
        key: "externalCCTV",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have External Lighting",
        key: "externalLighting",
        main: "siteEnergyData"
    ),
    (
        question: "That does / does not have Automatic Barrier(s)",
        key: "automaticBarrier",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have Automatic Gates (Sliding)",
        key: "automaticGatesSliding",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have Automatic Gates (Hinged)",
        key: "automaticGatesHinged",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have Manual Swing Gates",
        key: "manualSwingGates",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have Hard Landscaping",
        key: "hardLandScaping",
        main: "siteLandScapeData"
    ),
    (
        question: "That does / does not have Soft Landscaping",
        key: "softLandScaping",
        main: "siteLandScapeData"
    ),
    (
        question: "That does / does not have any Rivers/Ponds/Lakes nearby",
        key: "riverPondLakes",
        main: "siteLandScapeData"
    ),
    (
        question: "That does / does not have Tall Trees within its grounds",
        key: "tallTrees",
        main: "siteLandScapeData"
    ),
    (
        question: "That does / does not have Drainage Interceptors",
        key: "drainageInterceptors",
        main: "siteLandScapeData"
    ),
    (
        question: "That does / does not house any Third Party Telecoms Equipment",
        key: "thirdPartyTelEquipment",
        main: "siteLandScapeData"
    ),
    (
        question:
            "That does / does not have any Electrical Overhead Power Lines over-sailing the site",
        key: "electricalOverHeadPowerLines",
        main: "siteLandScapeData"
    ),
    (
        question: "That does / does not have Oil/Petrol Storage on Site",
        key: "oilStorageOnSite",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have LPG Storage on Site",
        key: "lpgStorageOnSite",
        main: "siteSafetyData"
    ),
    (
        question: "That does / does not have LPG Bulk Storage on Site",
        key: "lpgBulkStorageOnSite",
        main: "siteSafetyData"
    ),
]
