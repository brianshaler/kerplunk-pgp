###
# Key schema
###

module.exports = (mongoose) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  KeySchema = new Schema
    name:
      required: true
      type: String
      index:
        unique: true
    privateKey:
      required: true
      type: String
    publicKey:
      required: true
      type: String
    updatedAt:
      type: Date
      default: Date.now
    createdAt:
      type: Date
      default: Date.now

  mongoose.model 'Key', KeySchema
