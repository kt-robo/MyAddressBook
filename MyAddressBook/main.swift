//
//  main.swift
//  MyAddressBook
//
//  Created by kouta on 2015/11/06.
//  Copyright © 2015年 kouta. All rights reserved.
//

import Foundation

class AddressElement {
    var MemoryNumber: Int
    var FullName: String
    var PhoneticFirstName: String
    var PhoneticLastName: String
    var Telephone: [String]
    var EMail: [String]
    var PostalCode: String
    var Address: String
    var Note: String
    var BirthDay: String
    var URL: String
    var Organization: String
    var Role: String
    var GEO_Latitude: float_t   // 緯度
    var GEO_Longitude: float_t  // 経度
    var GroupNumber: Int
    var GroupName: String

    init(line: String) {
        var tokens: [String] = separateToToken(line)
        MemoryNumber = tokens[2].isEmpty ? -1:Int(tokens[2])!
        FullName = tokens[3]
        (PhoneticLastName, PhoneticFirstName) = getPhoneticNames(tokens[4])
        Telephone = []
        addString(&Telephone, string: tokens[5])
        EMail = []
        addString(&EMail, string: tokens[6])
        PostalCode = tokens[7]
        Address = tokens[8]
        Note = tokens[9]
        BirthDay = tokens[10]
        URL = tokens[11]
        Organization = tokens[12]
        Role = tokens[13]
        addString(&Telephone, string: tokens[14])
        addString(&EMail, string: tokens[15])
        addString(&Telephone, string: tokens[16])
        addString(&EMail, string: tokens[17])
        addString(&Telephone, string: tokens[18])
        addString(&EMail, string: tokens[19])
        addString(&Telephone, string: tokens[20])
        addString(&EMail, string: tokens[21])
        GEO_Latitude = tokens[22].isEmpty ? -1.0:Float(tokens[22])!
        GEO_Longitude = tokens[23].isEmpty ? -1.0:Float(tokens[23])!
        GroupNumber = tokens[28].isEmpty ? -1:Int(tokens[28])!
        GroupName = tokens[29]
    }

    func printVCard() {
        printCRLF("BEGIN:VCARD")
        printCRLF("VERSION:2.1")

        printWithUtf8("N", val: getNameString())
        printWithUtf8("FN", val: FullName)

        printWithUtf8("X-PHONETIC-FIRST-NAME", val: PhoneticFirstName)
        printWithUtf8("X-PHONETIC-LAST-NAME", val: PhoneticLastName)

        for tel in Telephone {
            printWithCharset("TEL", charset: "", val: tel)
        }

        for email in EMail {
            printWithCharset("EMAIL", charset: "", val: email)
        }

        printWithUtf8("ADR", val: getAddressString())

        printWithUtf8("NOTE", val: Note)

        printWithCharset("BDAY", charset: "", val: BirthDay)

        printWithCharset("URL", charset: "", val: URL)

        printWithUtf8("ORG", val: Organization)
        printWithUtf8("ROLE", val: Role)

        if GEO_Latitude != -1.0 || GEO_Longitude != -1.0 {
            let geo = ((GEO_Latitude == -1.0) ? "":String(GEO_Latitude)) + ":" + ((GEO_Longitude == -1.0) ? "":String(GEO_Longitude))
            printWithCharset("GEO", charset: "", val: geo)
        }

        printWithCharset("X-GNO", charset: "", val: String(GroupNumber))
        printWithUtf8("X-GN", val: GroupName)

        printCRLF("END:VCARD")
    }

    func testPrint() {
        print("MemoryNumber = " + String(MemoryNumber))
        print("FullName = '" + FullName + "'")
        print("PhoneticNames = '" + PhoneticFirstName + "' : '" + PhoneticLastName + "'")
        for i in 0..<Telephone.count {
            print("Telephone[\(i)] = '" + Telephone[i] + "'")
        }
        for i in 0..<EMail.count {
            print("EMail[\(i)] = '" + EMail[i] + "'")
        }
        print("PostalCode = '" + PostalCode + "'")
        print("Address = '" + Address + "'")
        print("Note = '" + Note + "'")
        print("BirthDay = '" + BirthDay + "'")
        print("URL = '" + URL + "'")
        print("Organization = '" + Organization + "'")
        print("Role = '" + Role + "'")
        print("GEO = \(GEO_Latitude) : \(GEO_Longitude)")
        print("GroupNumber = " + String(GroupNumber))
        print("GroupName = '" + GroupName + "'")
    }

    func getNameString() -> String {
        // "N"は名前の5要素を";"でつないだ文字列
        var names = FullName.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
        // namesが5要素より多ければ、6番目以降の要素は5番目の要素に" "でつなぐ
        let NAME_ELEMENTS_COUNT = 5
        if names.count > NAME_ELEMENTS_COUNT {
            for i in NAME_ELEMENTS_COUNT..<names.count {
                names[NAME_ELEMENTS_COUNT - 1] += " " + names[NAME_ELEMENTS_COUNT]
                names.removeAtIndex(NAME_ELEMENTS_COUNT)
            }
        }
        var name: String = ""
        for i in 0..<NAME_ELEMENTS_COUNT {
            if (i < names.count) {
                name += names[i]
            }
            if (i < 4) {
                name += ";"
            }
        }
        return name
    }

    func getAddressString() -> String {
        let ADDR_ELEMENTS_COUNT = 6
        var address: String = ""
        if (!PostalCode.isEmpty && !Address.isEmpty) {
            var addresses: [String] = []
            if (!Address.isEmpty) {
                addresses = Address.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ";"))
                // addressesが6要素より多ければ、7番目以降の要素は6番目の要素に" "でつなぐ
                if (addresses.count > ADDR_ELEMENTS_COUNT) {
                    for i in ADDR_ELEMENTS_COUNT..<addresses.count {
                        addresses[ADDR_ELEMENTS_COUNT - 1] += " " + addresses[ADDR_ELEMENTS_COUNT]
                        addresses.removeAtIndex(ADDR_ELEMENTS_COUNT)
                    }
                }
                for i in addresses.count..<ADDR_ELEMENTS_COUNT {
                    address += ";"
                }
                for var i = addresses.count - 1 ; i <= 1 ; i-- {
                    address += addresses[i] + ";"
                }
                address += PostalCode + ";"
                address += addresses[0]
            }
        }
        return address
    }
}

func separateToToken(line: String) -> [String] {
    var tokens: [String] = line.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
    var ret: [String] = []
    for i in 0..<tokens.count {
        if (tokens[i].isEmpty) {
            ret.append(tokens[i])
            continue;
        }
        if tokens[i][tokens[i].startIndex] == "\"" {
            tokens[i] = (tokens[i] as NSString).substringFromIndex(1)
        }
        if tokens[i][tokens[i].endIndex.predecessor()] == "\"" {
            tokens[i] = tokens[i].substringToIndex(tokens[i].endIndex.predecessor())
        }
        ret.append(convertHankakuKANAToZenkakuKANA(tokens[i]))
    }
    return ret
}

func getPhoneticNames(token: String) -> (String, String) {
    var names: [String] = token.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " ,"))
    if names.count == 1 {
        names.append("")
    }
    return (convertKatakanaToHiragana(names[0]), convertKatakanaToHiragana(names[1]))
}

func convertHankakuKANAToZenkakuKANA(str_in: String) -> String {
    let hankaku_ten:    UInt32  = 0x0000ff65
    let hankaku_wo:     UInt32  = 0x0000ff66
    let hankaku_la:     UInt32  = 0x0000ff67
    let hankaku_lo:     UInt32  = 0x0000ff6b
    let hankaku_lya:    UInt32  = 0x0000ff6c
    let hankaku_lyo:    UInt32  = 0x0000ff6e
    let hankaku_ltu:    UInt32  = 0x0000ff6f
    let hankaku_bou:    UInt32  = 0x0000ff70
    let hankaku_a:      UInt32  = 0x0000ff71
    let hankaku_u:      UInt32  = 0x0000ff73
    let hankaku_o:      UInt32  = 0x0000ff75
    let hankaku_ka:     UInt32  = 0x0000ff76
    let hankaku_ti:     UInt32  = 0x0000ff81
    let hankaku_tu:     UInt32  = 0x0000ff82
    let hankaku_to:     UInt32  = 0x0000ff84
    let hankaku_na:     UInt32  = 0x0000ff85
    let hankaku_no:     UInt32  = 0x0000ff89
    let hankaku_ha:     UInt32  = 0x0000ff8a
    let hankaku_ho:     UInt32  = 0x0000ff8e
    let hankaku_ma:     UInt32  = 0x0000ff8f
    let hankaku_mo:     UInt32  = 0x0000ff93
    let hankaku_ya:     UInt32  = 0x0000ff94
    let hankaku_yo:     UInt32  = 0x0000ff96
    let hankaku_ra:     UInt32  = 0x0000ff97
    let hankaku_ro:     UInt32  = 0x0000ff9b
    let hankaku_wa:     UInt32  = 0x0000ff9c
    let hankaku_n:      UInt32  = 0x0000ff9d
    let hankaku_daku:   UInt32  = 0x0000ff9e
    let hankaku_handaku: UInt32 = 0x0000ff9f

    let zenkaku_daku:   UInt32  = 0x0000309b
    let zenkaku_handaku: UInt32 = 0x0000309c
    let zenkaku_la:     UInt32  = 0x000030a1
    let zenkaku_a:      UInt32  = 0x000030a2
    let zenkaku_ka:     UInt32  = 0x000030ab
    let zenkaku_ga:     UInt32  = 0x000030ac
    let zenkaku_ltu:    UInt32  = 0x000030c3
    let zenkaku_tu:     UInt32  = 0x000030c4
    let zenkaku_du:     UInt32  = 0x000030c5
    let zenkaku_na:     UInt32  = 0x000030ca
    let zenkaku_ha:     UInt32  = 0x000030cf
    let zenkaku_ba:     UInt32  = 0x000030d0
    let zenkaku_pa:     UInt32  = 0x000030d1
    let zenkaku_ma:     UInt32  = 0x000030de
    let zenkaku_lya:    UInt32  = 0x000030e3
    let zenkaku_ya:     UInt32  = 0x000030e4
    let zenkaku_ra:     UInt32  = 0x000030e9
    let zenkaku_wa:     UInt32  = 0x000030ef
    let zenkaku_wo:     UInt32  = 0x000030f2
    let zenkaku_n:      UInt32  = 0x000030f3
    let zenkaku_vu:     UInt32  = 0x000030f4
    let zenkaku_ten:    UInt32  = 0x000030fb
    let zenkaku_bou:    UInt32  = 0x000030fc

    var char_out: [Character] = []
    var val_before: UInt32 = 0
    for char_in in str_in.unicodeScalars {
        var val_current: UInt32
        switch char_in.value {
        case hankaku_ten:
            val_current = zenkaku_ten
        case hankaku_wo:
            val_current = zenkaku_wo
        case hankaku_la...hankaku_lo:
            val_current = zenkaku_la + (char_in.value - hankaku_la) * 2
        case hankaku_lya...hankaku_lyo:
            val_current = zenkaku_lya + (char_in.value - hankaku_lya) * 2
        case hankaku_ltu:
            val_current = zenkaku_ltu
        case hankaku_bou:
            val_current = zenkaku_bou
        case hankaku_a...hankaku_o:
            val_current = zenkaku_a + (char_in.value - hankaku_a) * 2
        case hankaku_ka...hankaku_ti:
            val_current = zenkaku_ka + (char_in.value - hankaku_ka) * 2
        case hankaku_tu...hankaku_to:
            val_current = zenkaku_tu + (char_in.value - hankaku_tu) * 2
        case hankaku_na...hankaku_no:
            val_current = zenkaku_na + (char_in.value - hankaku_na)
        case hankaku_ha...hankaku_ho:
            val_current = zenkaku_ha + (char_in.value - hankaku_ha) * 3
        case hankaku_ma...hankaku_mo:
            val_current = zenkaku_ma + (char_in.value - hankaku_ma)
        case hankaku_ya...hankaku_yo:
            val_current = zenkaku_ya + (char_in.value - hankaku_ya) * 2
        case hankaku_ra...hankaku_ro:
            val_current = zenkaku_ra + (char_in.value - hankaku_ra)
        case hankaku_wa:
            val_current = zenkaku_wa
        case hankaku_n:
            val_current = zenkaku_n
        case hankaku_daku:
            switch val_before {
            case hankaku_u:
                val_current = zenkaku_vu
                char_out.removeLast()
            case hankaku_ka...hankaku_ti:
                val_current = zenkaku_ga + (val_before &- hankaku_ka) &* 2
                char_out.removeLast()
            case hankaku_tu...hankaku_to:
                val_current = zenkaku_du + (val_before &- hankaku_tu) &* 2
                char_out.removeLast()
            case hankaku_ha...hankaku_ho:
                val_current = zenkaku_ba + (val_before &- hankaku_ha) &* 3
                char_out.removeLast()
            default:
                val_current = zenkaku_daku
            }
        case hankaku_handaku:
            if val_before >= hankaku_ha && val_before <= hankaku_ho {
                val_current = zenkaku_pa + (val_before &- hankaku_ha) &* 3
                char_out.removeLast()
            } else {
                val_current = zenkaku_handaku
            }
        default:
            val_current = char_in.value
        }
        char_out.append(Character(UnicodeScalar(val_current)))
        val_before = char_in.value
    }
    return String(char_out)
}

func convertKatakanaToHiragana(str_in: String) -> String {
    let katakana_la:     UInt32  = 0x000030a1
    let katakana_vu:     UInt32  = 0x000030f4

    let hiragana_la:     UInt32  = 0x00003041

    var char_out: [Character] = []
    var in_val: UInt32
    var out_val: UInt32
    for char_in in str_in.unicodeScalars {
        in_val = char_in.value
        if in_val >= katakana_la && in_val <= katakana_vu {
            out_val = hiragana_la + (in_val - katakana_la)
        } else {
            out_val = in_val
        }
        char_out.append(Character(UnicodeScalar(out_val)))
    }
    return String(char_out)
}

func addString(inout array: [String], string: String) {
    if (!string.isEmpty) {
        array.append(string)
    }
}

func readFile(filePath: String) -> [String] {
    var result: [String] = []
    do {
        let csvString = try NSString(contentsOfFile: filePath, encoding: NSShiftJISStringEncoding) as String
        csvString.enumerateLines { (line, stop) -> () in
            result.append(line)
        }
    } catch {
        print("Error occurred in \"\(filePath)");
    }
    return result
}

func printWithUtf8(tag: String, val: String) {
    if !val.isEmpty {
        printWithCharset(tag, charset: "CHARSET=UTF-8", val: val)
    }
}

func printWithCharset(tag: String, charset: String, val: String) {
    if tag.isEmpty || val.isEmpty {
        return
    }
    printCRLF(tag + (charset.isEmpty ? "":(";" + charset)) + ":" + val)
}

func printCRLF(str: String) {
    print(str, terminator:"\r\n")
}

var args = Process.arguments
args.removeFirst()
if args.isEmpty {
    print("Usage: MyAddressBook csv-file [...]")
    exit(0)
}
for arg in args {
    var result = readFile(arg)
    result.removeFirst()
    for line in result {
        var element: AddressElement = AddressElement(line: line)
        element.printVCard()
    }
}

