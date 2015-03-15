/**
 * @name exemple
 * @desc Hello
 * @p_param{string} param
 * @returns {boolean}
 */
function exemple(p_param) {
    try {
        return true;
    } catch (er) {
        log(0, "ERROR(checkAuth):" + er.message);
        return false;
    }
}