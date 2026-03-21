module web.services.tool;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;

import vibe.web.auth;
import vibe.web.common : noRoute;

import model.model;
import model.entities.category;
import web.api.tool;

import web.services.common.auth;
import web.services.common.exceptions;
import web.services.common.todto;

class ToolService : ToolAPI
{
    this(Model model, AuthProvider authProvider)
    {
        m_model = model;
        m_authProvider = authProvider;
    }

    @safe override QuickAddResponseDTO quickAddConditions(in QuickAddInputDTO c)
    {
        return remapExceptions!(delegate() {
            auto result = m_model.quickAddConditions(c.type, c.expressions, c.categoryId, c.proxyRuleId);
            
            auto conditionDTOs = result.conditions.map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array;

            auto errorDTOs = result.errors.map!(e => toDTO(e))
                .array
                .sort!((a, b) => a.expression < b.expression, SwapStrategy.stable)
                .array;

            QuickAddResponseDTO response = {
                conditions: conditionDTOs,
                errors: errorDTOs,
            };
            return response;
        }, QuickAddResponseDTO);
    }

    mixin authMethodImpl;

private:
    Model m_model;
}
