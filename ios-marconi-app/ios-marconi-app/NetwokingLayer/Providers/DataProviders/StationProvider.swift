import FutureKit
import Foundation

struct StationProvider: ResponseValidator {
    
    private let _router: AnyRouter<StationApi>
    
    func fetch(by id: Int) -> Future<Station> {
        return _router.doRequest(.getStation(Id: id))
                      .validateResponse(networkManager: self)
                      .decoded()
    }
    
    func cancel() {
        _router.cancel()
    }
    
    init(_ router: AnyRouter<StationApi> = .init()) {
        _router = router
    }
}
