//
//  DatabaseConfigurable+Configuration.swift
//  RealmManager
//
//  Created by Admin on 2022/07/14.
//

import RealmSwift
//import RxSwift

// MARK: Configure
extension DatabaseConfigurable {
    private func configuration(memoryType: RealmMemoryType) throws -> Realm.Configuration {
        switch memoryType {
        case .inStorage: return try inStorageConfigure()
        case .inMemory: return try inMemoryConfigure(identifier: memoryType.associated)
        }
    }

    /// inStorageConfigure Use when you want to get storage configuration. You just choose enum inStorage.
    /// This method will get all important information property from the self instance.
    /// - Returns: Realm Configuration
    private func inStorageConfigure() throws -> Realm.Configuration {
        var anyObjectTypes: [ObjectBase.Type] = []
        objectTypes?.forEach({ anyObjectTypes.append($0) })
        embeddedObjectTypes?.forEach({ anyObjectTypes.append($0) })

        let realmConfig = Realm.Configuration(fileURL: path,
                                              readOnly: false,
                                              schemaVersion: absolutelySchemaVersion,
                                              migrationBlock: absolutelyMigrationBlock,
                                              objectTypes: anyObjectTypes)
        guard realmConfig.fileURL != nil else { throw RealmErrorType.configurationFailure }
        #if DEBUG
        print("realmConfig.fileURL = \(String(describing: realmConfig.fileURL))")
        #endif
        return realmConfig
    }

    /// inMemoryConfigure Use when you want to get memory configuration.
    /// You just choose an enum inMemory type and assign an identifier.
    /// - Parameter identifier: identifier choose
    /// - Returns: Realm Configuration
    private func inMemoryConfigure(identifier: String?) throws -> Realm.Configuration {
        if let identifier = identifier {
            var realmConfig = Realm.Configuration(inMemoryIdentifier: identifier)
            realmConfig.readOnly = false

            return realmConfig
        } else {
            throw RealmErrorType.configurationFailure
        }
    }

    func realm() -> Realm? {
        guard let configuration = try? self.configuration(memoryType: realmMemoryType) else { return nil }
        guard let realm = try? Realm(configuration: configuration) else { return nil }
        return realm
    }

    // MARK: Non-Rx
    func save(entity: Object, update: Bool, completion: @escaping (Result<Bool, RealmErrorType>) -> Void) {
        guard let realm = self.realm() else {
            completion(.failure(.realmIsEmpty))
            return
        }

        realm.writeAsync {
            if update {
                realm.add(entity, update: .all)
            } else {
                realm.add(entity)
            }
        } onComplete: { error in
            if error != nil {
                NSLog("error realm transaction: \(error!)")
                completion(.failure(RealmErrorType.transactionFailed))
            } else {
                completion(.success(true))
            }
        }
    }

    func save(entities: [Object], update: Bool = true, completion: @escaping (Result<Bool, RealmErrorType>) -> Void) {
        guard let realm = self.realm() else {
            completion(.failure(.realmIsEmpty))
            return
        }
        realm.writeAsync {
            for entity in entities {
                realm.add(entity, update: update ? .all : .error)
            }
        } onComplete: { error in
            if error != nil {
                NSLog("error realm transaction: \(error!)")
                completion(.failure(RealmErrorType.transactionFailed))
            } else {
                completion(.success(true))
            }
        }
    }

    func save<T>(saveClass: T.Type, jsonData: Data, update: Bool, completion: @escaping (Result<Bool, RealmErrorType>) -> Void) where T: Object  {
        guard let realm = self.realm() else {
            completion(.failure(.realmIsEmpty))
            return
        }

        realm.writeAsync {
            if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
                realm.create(saveClass.self, value: json)
            }
        } onComplete: { error in
            if error != nil {
                NSLog("error realm transaction: \(error!)")
                completion(.failure(RealmErrorType.transactionFailed))
            } else {
                completion(.success(true))
            }
        }

    }


    func delete(entity: Object, update: Bool = true, completion: @escaping (Result<Bool, RealmErrorType>) -> Void) {
        guard let realm = self.realm() else {
            completion(.failure(.realmIsEmpty))
            return
        }

        realm.writeAsync {
            realm.delete(entity)
        } onComplete: { error in
            if error != nil {
                NSLog("error realm transaction: \(error!)")
                completion(.failure(RealmErrorType.transactionFailed))
            } else {
                completion(.success(true))
            }
        }
    }
}

