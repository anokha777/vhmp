# Service center signup payload
{
	"name": "Nissan Service Center",
	"mobileNum": "1234567890",
	"username": "banga3",
	"password": "123",
	"role": "ROLE_SERVICE_CENTER",
	"address": "Electronic City, Bengaluru, Karnataka 560100"
}

# Car owner signup payload
{
	"name": "banga7",
	"mobileNum": "1234567890",
	"username": "banga7",
	"password": "123",
	"vehicleModel": "KA 08 5678",
	"role": "ROLE_USER"
}

# Insert into carissues, db script
db.carissues.insert({
  carOwner: ObjectId("5e4e2f76f7ec673ae1273662"),
  carError: ObjectId("5e4e3d34f0b875b145423bc6"),
  issueState: "Un-Resolved",
  createDatetime: ISODate("2020-02-20T07:27:01.846Z")
})