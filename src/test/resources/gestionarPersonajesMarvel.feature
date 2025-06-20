@DEV_TEST_AUTOMATISATION @MarvelCharactersCrud
Feature: MARVEL-API API REST de personajes de Marvel (microservicio para gestionar personajes de Marvel)
  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser'
    * path '/api/characters'
    * def generarHeaders =
      """
      function() {
        return {
          "Content-Type": "application/json"
        };
      }
      """
    * def headers = generarHeaders()
    * headers headers
    * def id = null
    * def name = java.util.UUID.randomUUID().toString()

  @id:1 @obtenerPersonajes @solicitudExitosa200
  Scenario: T-API-MARVEL-API-CA01-Obtener todos los personajes 200 - karate
    When method GET
    Then status 200
  # And match response != null
  # And match response == '#array'

  @id:2 @crearPersonaje @solicitudExitosa201
  Scenario: T-API-MARVEL-API-CA04-Crear personaje exitosamente 201 - karate
    * def jsonData =
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    And request jsonData
    When method POST
    Then status 201
    * def id = response.id
    * print 'ID creado:', id
    * eval karate.write({ id: id }, 'target/personaje-id.json')

  @id:3 @obtenerPersonajePorId @solicitudExitosa200
  Scenario: T-API-MARVEL-API-CA02-Obtener personaje por ID exitoso 200 - karate
    * def data = read('target/personaje-id.json')
    * print 'ID del personaje:', data
    * def id = data.id
    * path '/' + id
    When method GET
    Then status 200
  # And match response != null
  # And match response.id == 1

  @id:4 @obtenerPersonajePorId @notFound404
  Scenario: T-API-MARVEL-API-CA03-Obtener personaje por ID no existente 404 - karate
    * def characterId = '999'
    * path '/' + characterId
    When method GET
    Then status 404
  # And match response.error == 'Character not found'
  # And match response == { error: 'Character not found' }

  @id:5 @crearPersonaje @errorValidacion400
  Scenario: T-API-MARVEL-API-CA05-Crear personaje con datos inválidos 400 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_invalid_character.json')
    And request jsonData
    When method POST
    Then status 400
  # And match response.name == 'Name is required'
  # And match response.alterego == 'Alterego is required'

  @id:6 @crearPersonaje @errorDuplicado400
  Scenario: T-API-MARVEL-API-CA06-Crear personaje con nombre duplicado 400 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    # Primero creamos un personaje
    And request jsonData
    When method POST
    Then status 400

  @id:7 @actualizarPersonaje @solicitudExitosa200
  Scenario: T-API-MARVEL-API-CA07-Actualizar personaje exitosamente 200 - karate
    * def characterId = '1'
    * path '/' + characterId
    * def jsonData = read('classpath:data/marvel_characters_api/request_update_character.json')
    And request jsonData
    When method PUT
    Then status 200
  # And match response != null
  # And match response.description == 'Updated description'

  @id:8 @actualizarPersonaje @notFound404
  Scenario: T-API-MARVEL-API-CA08-Actualizar personaje no existente 404 - karate
    * def characterId = '999'
    * path '/' + characterId
    * def jsonData = read('classpath:data/marvel_characters_api/request_update_character.json')
    And request jsonData
    When method PUT
    Then status 404
  # And match response.error == 'Character not found'
  # And match response == { error: 'Character not found' }

  @id:9 @eliminarPersonaje @solicitudExitosa204
  Scenario: T-API-MARVEL-API-CA09-Eliminar personaje exitosamente 204 - karate
    * def characterId = '1'
    * path '/' + characterId
    When method DELETE
    Then status 204
  # And match response == ''
  # And match responseBytes == ''

  @id:10 @eliminarPersonaje @notFound404
  Scenario: T-API-MARVEL-API-CA10-Eliminar personaje no existente 404 - karate
    * def characterId = '999'
    * path '/' + characterId
    When method DELETE
    Then status 404
  # And match response.error == 'Character not found'
  # And match response == { error: 'Character not found' }

  @id:11 @errorServicio500
  Scenario: T-API-MARVEL-API-CA11-Error interno del servidor 500 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * set jsonData.name = 'ErrorServer500'
    And request jsonData
    When method POST
    Then status 400
  # And match response.status == 500
  # And match response.message contains 'Error interno del servidor'
