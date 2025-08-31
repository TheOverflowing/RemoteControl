//
// Created by no3core on 2023/8/24.
//

#include <regex>
#include "UserApi.h"

User::User() {

}

User::User(map<string,string>& userInfo){
    if(!userInfo["id"].empty())
        id = stoi(userInfo["id"]);
    username = userInfo["username"];
    password = userInfo["password"];
    nickname = userInfo["nickname"];
    color = userInfo["color"];
    avatar = userInfo["avatar"];
    user_type = userInfo["user_type"];
    if(user_type.empty()) {
        user_type = "normal"; // 默认为普通用户
    }
}

User::~User() {

}

UserApi::UserApi(UserService *userService) :
    userService(userService) {}

User User::formJsonObject(const QJsonObject &json){
    map<string,string> reqParams = jsonToString(json);
    User user = User(reqParams);
    return user;
}

QJsonObject User::toJsonObject(const User& user) {
    QJsonObject userObject{
            {"id", user.id},
            {"username", QString::fromStdString(user.username)},
            {"nickname", QString::fromStdString(user.nickname)},
            {"color", QString::fromStdString(user.color)},
            {"avatar", QString::fromStdString(user.avatar)},
            {"user_type", QString::fromStdString(user.user_type)}
    };
    return userObject;
}

QJsonObject User::toJsonObjectForLogin(const User& user,const QUuid& token){
    QJsonObject userObject = toJsonObject(user);
    QJsonObject jsonObject{
            {"user", userObject},
            {"cookie", token.toString(QUuid::StringFormat::WithoutBraces)}
    };
    return jsonObject;
}

QJsonArray User::toJsonObjectForInfos(const vector<User>& rc) {
    QJsonArray jsonArray;

    for (const auto &user: rc) {
        QJsonObject userJson = User::toJsonObject(user); // 请将正确的 token 参数传递给函数

        jsonArray.append(userJson);
    }
    return jsonArray;
}

QJsonObject User::toJsonObjectForUserip(const string& ipPortString) {
    size_t colonPos = ipPortString.find(":");
    string ip = ipPortString.substr(0, colonPos);
    string port = ipPortString.substr(colonPos + 1);

    QJsonObject jsonObject;
    jsonObject["ip"] = QString::fromStdString(ip);
    jsonObject["port"] = QString::fromStdString(port);

    return jsonObject;
}

QHttpServerResponse UserApi:: registerSession(const QHttpServerRequest &request) {
    const auto json = byteArrayToJsonObject(request.body());

    if (!json)
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    User user = User::formJsonObject(json.value());
    if (user.username.empty()||
        user.password.empty()||
        user.nickname.empty()||
        user.color.empty()||
        user.avatar.empty())
        return QHttpServerResponse(QJsonObject{{"msg","请输入完整的username,password,nickname,avatar,color,且不能为空"}},QHttpServerResponder::StatusCode::BadRequest);

    if (userService->isUsernameExists(user.username)) {
        return QHttpServerResponse(QJsonObject{{"msg","用户名已存在，请重试"}},QHttpServerResponder::StatusCode::BadRequest);
    }

    if (userService->isNicknameExists(user.nickname)) {
        return QHttpServerResponse(QJsonObject{{"msg","昵称已存在，请重试"}}, QHttpServerResponder::StatusCode::BadRequest);
    }
    
    // 验证专家验证码
    string expertCode = "";
    if (json.value().contains("expert_code")) {
        expertCode = json.value()["expert_code"].toString().toStdString();
    }
    
    if (!expertCode.empty()) {
        if (expertCode == "1111") {
            user.user_type = "expert";
        } else {
            return QHttpServerResponse(QJsonObject{{"msg","专家验证码错误"}}, QHttpServerResponder::StatusCode::BadRequest);
        }
    } else {
        user.user_type = "normal"; // 默认为普通用户
    }
    
    userService->insertUser(user);
    user = userService->selectUserInfoByName(user.username);
    SessionEntry sessionEntry = SessionApi::getInstance()->createEntryAndStart(user.id);

//    string clientAddress = QHostAddress(request.remoteAddress().toIPv4Address()).toString().toStdString();
//    string clientPort = to_string(request.remotePort());
//    SessionApi::getInstance()->insertIP(to_string(user.id),clientAddress+":"+clientPort);

    QJsonObject qJsonObject = User::toJsonObjectForLogin(user,sessionEntry.token.value());
    return QHttpServerResponse(qJsonObject);
}

QHttpServerResponse UserApi:: login(const QHttpServerRequest &request) {
    const auto json = byteArrayToJsonObject(request.body());
    if (!json)
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    User user = User::formJsonObject(json.value());
    string username = user.username;
    string password = user.password;
    if (username.empty()||
        password.empty()){
        return QHttpServerResponse(QJsonObject{{"msg",
                "请输入完整的username,password,且不能为空"}},
                QHttpServerResponder::StatusCode::BadRequest
        );
    }
    user = userService->validateUserCredentials(username,password);
    if(user.username.empty())
        return QHttpServerResponse(QJsonObject{{"msg","用户名或密码错误"}},QHttpServerResponder::StatusCode::BadRequest);
    SessionEntry sessionEntry = SessionApi::getInstance()->createEntryAndStart(user.id);

//    string clientAddress = QHostAddress(request.remoteAddress().toIPv4Address()).toString().toStdString();
//    string clientPort    = to_string(request.remotePort());
//    SessionApi::getInstance()->insertIP(to_string(user.id),clientAddress+":"+clientPort);

    QJsonObject qJsonObject = User::toJsonObjectForLogin(user,sessionEntry.token.value());
    auto response =  QHttpServerResponse(qJsonObject);
    // simply set for debug in browser
    response.setHeader("Set-Cookie",sessionEntry.token.value().toByteArray());
    return response;

}

QHttpServerResponse UserApi::info(const QHttpServerRequest &request) {
    // get the cookie and auth it, fail then return
    auto cookie =  getcookieFromRequest(request);
    auto id = (cookie.has_value())?
               SessionApi::getInstance()->getIdByCookie(QUuid::fromString(cookie.value())):
               (std::nullopt);
    if(!id.has_value())
        return QHttpServerResponse(QJsonObject{{"msg","身份验证失败"}}, QHttpServerResponder::StatusCode::BadRequest);

    const auto json = byteArrayToJsonObject(request.body());
    if (!json)
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);

    User user = User::formJsonObject(json.value());
    string nickname = user.nickname;
    string color = user.color;
    string avatar = user.avatar;
    bool rc = userService->updateInfo(id.value(),nickname,color,avatar);
    if(!rc){
        return QHttpServerResponse(QJsonObject{{"msg","服务器内部错误"}}, QHttpServerResponder::StatusCode::InternalServerError);
    }
    return QHttpServerResponse("");
}

QHttpServerResponse UserApi::changePassword(const QHttpServerRequest &request) {
    // 获取cookie并验证身份
    auto cookie = getcookieFromRequest(request);
    auto id = (cookie.has_value()) ?
               SessionApi::getInstance()->getIdByCookie(QUuid::fromString(cookie.value())) :
               (std::nullopt);
    if(!id.has_value())
        return QHttpServerResponse(QJsonObject{{"msg","身份验证失败"}}, QHttpServerResponder::StatusCode::BadRequest);

    const auto json = byteArrayToJsonObject(request.body());
    if (!json)
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);

    // 解析请求参数
    auto oldPassword = json.value()["oldPassword"].toString().toStdString();
    auto newPassword = json.value()["newPassword"].toString().toStdString();
    
    if (oldPassword.empty() || newPassword.empty()) {
        return QHttpServerResponse(QJsonObject{{"msg","旧密码和新密码不能为空"}}, QHttpServerResponder::StatusCode::BadRequest);
    }
    
    // 调用服务层修改密码
    bool success = userService->changePassword(id.value(), oldPassword, newPassword);
    if (!success) {
        return QHttpServerResponse(QJsonObject{{"msg","旧密码不正确或修改失败"}}, QHttpServerResponder::StatusCode::BadRequest);
    }
    
    return QHttpServerResponse(QJsonObject{{"msg","密码修改成功"}});
}

QHttpServerResponse UserApi::infos(const QHttpServerRequest &request){
    const auto json = byteArrayToJsonObject(request.body());
    if (!json)
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    string uidParams = jsonToString(json.value())["uids"];
    if(uidParams.empty()){
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    }
    // TODO:here need to use regex to match the msg, we trust the client will give right form data
    // regex matc the uidparams be 1,2,3,4 like this, digitals split by comma
    std::regex pattern("\\d+(,\\d+)*");
    if(!std::regex_match(uidParams,pattern)){
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    }


    vector<User> rc = userService->getUserInfos(uidParams);
    QJsonArray qJsonArray = User::toJsonObjectForInfos(rc);
    return QHttpServerResponse(qJsonArray);
}

QHttpServerResponse UserApi::getUserip(const QHttpServerRequest &request){
    // get the cookie and auth it, fail then return
    auto cookie =  getcookieFromRequest(request);
    auto id = (cookie.has_value())?
               SessionApi::getInstance()->getIdByCookie(QUuid::fromString(cookie.value())):
               (std::nullopt);
    if(!id.has_value())
        return QHttpServerResponse(QJsonObject{{"msg","身份验证失败"}}, QHttpServerResponder::StatusCode::BadRequest);

    // auth query
    string uid = request.query().queryItemValue("uid").toStdString();
    if(uid.empty()){
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}},QHttpServerResponder::StatusCode::BadRequest);
    }
    auto ip = SessionApi::getInstance()->getIpById(uid);
    if(!ip.has_value()){
        return QHttpServerResponse(QJsonObject{{"msg","无法获取用户对应ip"}},QHttpServerResponder::StatusCode::BadRequest);
    }
    QJsonObject qJsonObject = User::toJsonObjectForUserip(ip.value());
    return QHttpServerResponse(qJsonObject);
}

QHttpServerResponse UserApi::onlines(const QHttpServerRequest &request){
    const auto json = byteArrayToJsonObject(request.body());
    if (!json)
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    string uidParams = jsonToString(json.value())["uids"];
    if(uidParams.empty()){
        return QHttpServerResponse(QJsonObject{{"msg","参数错误"}}, QHttpServerResponder::StatusCode::BadRequest);
    }
    QJsonArray qJsonArray = SessionApi::getInstance()->checkIdsInSet(uidParams);
    return QHttpServerResponse(qJsonArray);
}

//
//QHttpServerResponse UserApi::logout(const QHttpServerRequest &request) {
//    const auto maybecookie = getcookieFromRequest(request);
//    if (!maybecookie)
//        return QHttpServerResponse(QHttpServerResponder::StatusCode::BadRequest);
//
//    auto maybeSession = std::find(sessions.begin(), sessions.end(), *maybecookie);
//    if (maybeSession != sessions.end())
//        maybeSession->endSession();
//    return QHttpServerResponse(QHttpServerResponder::StatusCode::Ok);
//}
