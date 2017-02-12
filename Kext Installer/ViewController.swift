//
//  ViewController.swift
//  Kext Installer
//
//  Created by Daniele on 07/02/17.
//  Copyright © 2017 Daniele. All rights reserved.
//



//******** Probabilmente ottimizzabile visto che è un primo programma in swift ********//





import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var installefi: NSButton!
    @IBOutlet weak var kextstable: NSTableView!
    @IBOutlet weak var passwordField: NSTextField!
    @IBOutlet weak var labelversione: NSTextField!
    @IBOutlet weak var fieldversione: NSTextField!
    @IBAction func actioninstallefi(_ sender: NSButton) {
        if installefi.state == NSOnState{
            fieldversione.isHidden = false
            labelversione.isHidden = false
        }else{
            fieldversione.isHidden = true
            labelversione.isHidden = true
        }
    }

    var indice = -1
    
    var elementiVista: NSMutableArray! = NSMutableArray()
    var elementiAzione: NSMutableArray! = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        labelversione.isHidden = true
        fieldversione.isHidden = true
        self.kextstable.reloadData()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //imposta il numero di righe
    func numberOfRows(in tableView: NSTableView) -> Int {
        //in questo caso conta gli elementi dell'array elementi
        return self.elementiVista.count
    }
    
    //imposta le celle della tabella
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = kextstable.make(withIdentifier: "cell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.elementiVista.object(at: row) as! String
        return cellView
        
    }
    
    //se un elemento è selezionato compie l'azione
    func tableViewSelectionDidChange(_ notification: Notification) {
        //self.kextstable.selectedRow rappresenta l'indice dell'elemento selezionato (si può usare solo qua, quindi è meglio assegnare l'indice a una variabile globale in modo da renderla accessibile da ovunque
        let selectedItem = self.elementiVista.object(at: self.kextstable.selectedRow) as! String
        print(selectedItem)
        if self.kextstable.selectedRow != -1{
            indice = self.kextstable.selectedRow
        }else{
            print("Devi prima selezionare")
        }
        //self.kextstable.deselectRow(self.kextstable.selectedRow)
        
    }
    
    @IBAction func rimuovi(_ sender: NSButton) {
        
        self.elementiVista.removeObject(at: indice)
        self.elementiAzione.removeObject(at: indice)
        //Ricarica la teableview aggiornata
        self.kextstable.reloadData()
        
    }
    @IBAction func aggiungi(_ sender: NSButton) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Scegli il kext";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["kext", "bundle"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                self.elementiAzione.add(path)
                //filename_field.stringValue = path
                let nameFile = path
                // per ottenere solo il nome del file genero un array con gli elementi della stringa divisi da /
                let nameFileSplitted = nameFile.components(separatedBy: "/")
                // e poi prendo l'ultimo elemento
                self.elementiVista.add(nameFileSplitted[nameFileSplitted.count - 1])
            }
        } else {
            // User clicked on "Cancel"
            return
        }

        self.kextstable.reloadData()
    }
    @IBAction func Installa(_ sender: NSButton) {
        // per eseguire azioni come root uso gli applescript passando come password la stringa digitata su passwordField
        if installefi.state == NSOnState{
            NSAppleScript(source: "do shell script \"mkdir /Volumes/efi \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
            NSAppleScript(source: "do shell script \"mount -t msdos /dev/disk0s1 /Volumes/efi \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
            
            let efipartition = FileManager.default
            if efipartition.fileExists(atPath: "/Volumes/efi/EFI/CLOVER/kexts"){
                for kext in elementiAzione{
                    let nameFileSplitted = (kext as! String).components (separatedBy: "/")
                    NSAppleScript(source: "do shell script \"cp -R \\\"\(kext as! String)\\\" \\\"/Volumes/efi/EFI/CLOVER/kexts/\(fieldversione.stringValue)\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                    NSAppleScript(source: "do shell script \"chmod -R 755 \\\"/Volumes/efi/EFI/CLOVER/kexts/\(fieldversione.stringValue)/\(nameFileSplitted[nameFileSplitted.count - 1])\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                    NSAppleScript(source: "do shell script \"chown -R root:wheel \\\"/Volumes/efi/EFI/CLOVER/kexts/\(fieldversione.stringValue)/\(nameFileSplitted[nameFileSplitted.count - 1])\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                }
            } else {
                print("nada")
            }
            
            NSAppleScript(source: "do shell script \"diskutil unmount /Volumes/efi \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
            
            let efiroot = FileManager.default
            if efiroot.fileExists(atPath: "/EFI/CLOVER/kexts") {
                for kext in elementiAzione{
                    let nameFileSplitted = (kext as! String).components (separatedBy: "/")
                    NSAppleScript(source: "do shell script \"cp -R \\\"\(kext as! String)\\\" \\\"/EFI/CLOVER/kexts/\(fieldversione.stringValue)\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                    NSAppleScript(source: "do shell script \"chmod -R 755 \\\"//EFI/CLOVER/kexts/\(fieldversione.stringValue)/\(nameFileSplitted[nameFileSplitted.count - 1])\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                    NSAppleScript(source: "do shell script \"chown -R root:wheel \\\"/EFI/CLOVER/kexts/\(fieldversione.stringValue)/\(nameFileSplitted[nameFileSplitted.count - 1])\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                }
            } else {
                print("File not found")
            }
        }
        else{
            for kext in elementiAzione{
                let nameFileSplitted = (kext as! String).components (separatedBy: "/")
                NSAppleScript(source: "do shell script \"cp -R \\\"\(kext as! String)\\\" /System/Library/Extensions \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                NSAppleScript(source: "do shell script \"chmod -R 755 \\\"/System/Library/Extensions/\(nameFileSplitted[nameFileSplitted.count - 1])\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
                NSAppleScript(source: "do shell script \"chown -R root:wheel \\\"/System/Library/Extensions/\(nameFileSplitted[nameFileSplitted.count - 1])\\\" \" password \"\(passwordField.stringValue)\" with administrator " + "privileges")!.executeAndReturnError(nil)
            }
        }
        
    }

}

