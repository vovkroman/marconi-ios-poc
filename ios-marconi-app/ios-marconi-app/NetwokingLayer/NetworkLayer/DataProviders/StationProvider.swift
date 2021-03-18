import FutureKit
import Foundation

class StationProvider: ResponseValidator {
    
    private let _router: AnyRouter<StationApi>
    
    func fetch(by id: Int) -> Future<Movie> {
        return _router.doRequest(.getStation(Id: id))
                      .validateResponse(networkManager: self)
                      .decoded()
    }
    
    init(_ router: AnyRouter<StationApi> = .init()) {
        _router = router
    }
}
