describe "Hoodie.Share", ->  
  beforeEach ->
    @hoodie = new Mocks.Hoodie
    @share  = new Hoodie.Share @hoodie
    spyOn(@share, "instance")

  describe "constructor", ->
    it "should set Hoodie.ShareInstance.prototype.hoodie", ->
      new Hoodie.Share @hoodie
      instance = new Hoodie.ShareInstance
      expect(instance.hoodie).toBe @hoodie

  describe "direct call", ->
    beforeEach ->
      spyOn(@hoodie, "open")
    
    it "should proxy to hoodie.open('share/' + shareId, {prefix: 'share/shareId'}) and pass options", ->
      @share('funk123', option: 'value')
      expect(@hoodie.open).wasCalledWith 'share/funk123', prefix: 'share/funk123', option: 'value'
  # /('share_id', options)

  describe "#instance", ->
    it "should point to Hoodie.ShareInstance", ->
      share  = new Hoodie.Share @hoodie
      expect(share.instance).toBe Hoodie.ShareInstance
  # /#instance

  describe "#add(attributes)", ->
    beforeEach ->
      @instance      = jasmine.createSpy("instance")
      @instance.save = jasmine.createSpy("save")
      @share.instance.andReturn @instance
    
    it "should initiate a new Hoodie.ShareInstance and save it", ->
      returnValue = @share.add funky: 'fresh'
      expect(@share.instance).wasCalledWith funky: 'fresh'
      expect(@instance.save).wasCalled()
      expect(returnValue).toBe @instance
  # /#add(attributes)

  describe "#find(share_id)", ->
    beforeEach ->
      promise = @hoodie.defer().resolve(funky: 'fresh').promise()
      spyOn(@hoodie.store, "find").andReturn promise
      @share.instance.andCallFake -> this.foo = 'bar'
    
    it "should proxy to store.find('$share', share_id)", ->
      promise = @share.find '123'
      expect(@hoodie.store.find).wasCalledWith '$share', '123'

    it "should resolve with a Share Instance", ->
      @hoodie.store.find.andReturn @hoodie.defer().resolve({}).promise()
      @share.instance.andCallFake -> this.foo = 'bar'
      promise = @share.find '123'
      expect(promise).toBeResolvedWith foo: 'bar'
  # /#find(share_id)

  describe "#findOrAdd(id, share_attributes)", ->
    beforeEach ->
      spyOn(@hoodie.store, "findOrAdd").andCallThrough()
    
    it "should proxy to hoodie.store.findOrAdd with type set to '$share'", ->
      @share.findOrAdd 'id123', {}
      expect(@hoodie.store.findOrAdd).wasCalledWith '$share', 'id123', {}

    it "should resolve with a Share Instance", ->
      @hoodie.store.findOrAdd.andReturn @hoodie.defer().resolve({}).promise()
      @share.instance.andCallFake -> this.foo = 'bar'
      promise = @share.findOrAdd 'id123', {}
      expect(promise).toBeResolvedWith foo: 'bar'
  # /#findOrAdd(share_attributes)

  describe "#findAll()", ->
    beforeEach ->
      spyOn(@hoodie.store, "findAll").andCallThrough()
    
    it "should proxy to hoodie.store.findAll('$share')", ->
      @hoodie.store.findAll.andCallThrough()
      @share.findAll()
      expect(@hoodie.store.findAll).wasCalledWith '$share'

    it "should resolve with an array of Share instances", ->
      @hoodie.store.findAll.andReturn @hoodie.defer().resolve([{}, {}]).promise()
      @share.instance.andCallFake -> this.foo = 'bar'
      promise = @share.findAll()
      expect(promise).toBeResolvedWith [{foo: 'bar'}, {foo: 'bar'}]
  # /#findAll()

  describe "#save('share_id', attributes)", ->
    beforeEach ->
      spyOn(@hoodie.store, "save").andCallThrough()
    
    it "should proxy to hoodie.store.save('$share', 'share_id', attributes)", ->
      @share.save('abc4567', funky: 'fresh')
      expect(@hoodie.store.save).wasCalledWith '$share', 'abc4567', funky: 'fresh'

    it "should resolve with a Share Instance", ->
      @hoodie.store.save.andReturn @hoodie.defer().resolve({}).promise()
      @share.instance.andCallFake -> this.foo = 'bar'
      promise = @share.save {}
      expect(promise).toBeResolvedWith foo: 'bar'
  # /#save('share_id', attributes)

  describe "#update('share_id', changed_attributes)", ->
    beforeEach ->
      spyOn(@hoodie.store, "update").andCallThrough()
    
    it "should proxy to hoodie.store.update('$share', 'share_id', attributes)", ->
      @share.update('abc4567', funky: 'fresh')
      expect(@hoodie.store.update).wasCalledWith '$share', 'abc4567', funky: 'fresh'

    it "should resolve with a Share Instance", ->
      @hoodie.store.update.andReturn @hoodie.defer().resolve({}).promise()
      @share.instance.andCallFake -> this.foo = 'bar'
      promise = @share.update {}
      expect(promise).toBeResolvedWith foo: 'bar'
  # /#update('share_id', changed_attributes)


  describe "#updateAll(changed_attributes)", ->
    beforeEach ->
      spyOn(@hoodie.store, "updateAll").andCallThrough()
    
    it "should proxy to hoodie.store.updateAll('$share', changed_attributes)", ->
      @hoodie.store.updateAll.andCallThrough()
      @share.updateAll( funky: 'fresh' )
      expect(@hoodie.store.updateAll).wasCalledWith '$share', funky: 'fresh'

    it "should resolve with an array of Share instances", ->
      @hoodie.store.updateAll.andReturn @hoodie.defer().resolve([{}, {}]).promise()
      @share.instance.andCallFake -> this.foo = 'bar'
      promise = @share.updateAll funky: 'fresh'
      expect(promise).toBeResolvedWith [{foo: 'bar'}, {foo: 'bar'}]
  # /#findAll()


  describe "#remove(share_id)", ->
    beforeEach ->
      promise = @hoodie.defer().resolve(funky: 'fresh').promise()
      spyOn(@hoodie.store, "find").andReturn promise

      class @share.instance
        remove: -> 'delete_promise'
    
    it "should try to find the object with store.find('$share', share_id)", ->
      promise = @share.remove '123'
      expect(@hoodie.store.find).wasCalledWith '$share', '123'

    it "should init the share instance and remove it", ->
      @hoodie.store.find.andReturn @hoodie.defer().resolve({}).promise()
      promise = @share.remove '123'
      expect(promise).toBeResolvedWith 'delete_promise'
  # /#remove(share_id)


  describe "#removeAll()", ->
    beforeEach ->
      promise = @hoodie.defer().resolve([{funky: 'fresh'}, {funky: 'fresh'}]).promise()
      spyOn(@hoodie.store, "findAll").andReturn promise

      class @share.instance
        remove: -> 'removeAll_promise'
    
    it "should try to find the object with store.findAll('$share')", ->
      promise = @share.removeAll()
      expect(@hoodie.store.findAll).wasCalled()

    it "should init the share instance and remove it", ->
      @hoodie.store.findAll.andReturn @hoodie.defer().resolve([{}, {}]).promise()
      promise = @share.removeAll()
      expect(promise).toBeResolvedWith ['removeAll_promise', 'removeAll_promise']
  # /#removeAll()